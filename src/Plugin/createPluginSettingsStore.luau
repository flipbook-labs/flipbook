local HttpService = game:GetService("HttpService")

local Signals = require("@rbxpkg/Signals")

local PluginStore = require("@root/Plugin/PluginStore")

export type PluginSettingsStore<T> = {
	getStorage: Signals.getter<T>,
	setStorage: Signals.setter<T>,

	isSettingDefault: (settingName: string) -> boolean,

	getIsLoading: Signals.getter<boolean>,
	getErr: Signals.getter<string?>,

	dispose: () -> (),
}

local function createPluginSettingsStore<T>(
	storageKey: string,
	defaultValue: T,
	validate: (value: any) -> (boolean, string)
): PluginSettingsStore<T>
	local getStorage, setStorage = Signals.createSignal(defaultValue)
	local getIsLoading, setIsLoading = Signals.createSignal(true)
	local getErr, setErr = Signals.createSignal(nil :: string?)

	local function readPluginSettingsAsync(plugin: Plugin): T?
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

	local function writePluginSettingsAsync(plugin: Plugin, storage: T)
		local data = HttpService:JSONEncode(storage)
		if data then
			plugin:SetSetting(storageKey, data)
		end
	end

	local prevStorage: T?
	local dispose = Signals.createEffect(function(scope)
		local storage = getStorage(scope)
		local plugin = PluginStore.get(scope).getPlugin(scope)

		if plugin then
			if getIsLoading(false) then
				task.spawn(function()
					local data = readPluginSettingsAsync(plugin)
					if data then
						setStorage(data)
					end
					setIsLoading(false)
				end)
			end

			if storage ~= prevStorage then
				task.spawn(function()
					writePluginSettingsAsync(plugin, storage)
				end)
			end
		end

		prevStorage = storage
	end)

	local function isSettingDefault(settingName: string): boolean
		local storage = getStorage(false)
		if typeof(defaultValue) ~= "table" or typeof(storage) ~= "table" then
			return true
		end

		local settingDefaultValue = defaultValue[settingName]
		local storedValue = storage[settingName]

		return storedValue == nil or storedValue == settingDefaultValue
	end

	return {
		getIsLoading = getIsLoading,
		getErr = getErr,
		getStorage = getStorage,
		setStorage = setStorage,
		isSettingDefault = isSettingDefault,
		dispose = dispose,
	}
end

return createPluginSettingsStore
