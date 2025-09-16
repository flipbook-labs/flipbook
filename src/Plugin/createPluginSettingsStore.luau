local HttpService = game:GetService("HttpService")

local Signals = require("@rbxpkg/Signals")

export type PluginSettings = {
	userSettings: {
		[string]: string | number | boolean,
	}?,
	lastOpenedStoryPath: string?,
}

export type PluginSettingsStore<T> = {
	getStorage: Signals.getter<T>,
	setStorage: Signals.setter<T>,

	getIsLoading: Signals.getter<boolean>,
	getErr: Signals.getter<string?>,
}

local function createPluginSettingsStore<T>(
	plugin: Plugin,
	storageKey: string,
	defaultValue: T,
	validate: (value: any) -> (boolean, string)
): PluginSettingsStore<T>
	local getStorage, setStorage = Signals.createSignal(defaultValue)
	local getIsLoading, setIsLoading = Signals.createSignal(true)
	local getErr, setErr = Signals.createSignal(nil :: string?)

	local function readPluginSettingsAsync(): T?
		local data = plugin:GetSetting(storageKey)

		if typeof(data) == "string" then
			local success, result = pcall(function()
				return HttpService:JSONDecode(data)
			end)

			if not success then
				setErr(result)
				return nil
			end

			local isValid, message = validate(result)

			if not isValid then
				setErr(message)
				return nil
			end

			return result
		end
		return nil
	end

	local function writePluginSettingsAsync(storage: T)
		local data = HttpService:JSONEncode(storage)
		if data then
			plugin:SetSetting(storageKey, data)
		end
	end

	task.spawn(function()
		local data = readPluginSettingsAsync()
		if data then
			setStorage(data)
		end
		setIsLoading(false)
	end)

	local dispose = Signals.createEffect(function(scope)
		local storage = getStorage(scope)

		task.spawn(function()
			writePluginSettingsAsync(storage)
		end)
	end)

	return {
		getIsLoading = getIsLoading,
		getErr = getErr,
		getStorage = getStorage,
		setStorage = setStorage,
		dispose = dispose,
	}
end

return createPluginSettingsStore
