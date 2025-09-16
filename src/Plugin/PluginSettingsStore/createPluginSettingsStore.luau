local HttpService = game:GetService("HttpService")

local Signals = require("@rbxpkg/Signals")

export type PluginSettings = {
	userSettings: {
		[string]: string | number | boolean,
	}?,
	lastOpenedStoryPath: string?,
}

export type PluginSettingsStore = {
	get: Signals.getter<PluginSettings>,
	set: Signals.setter<PluginSettings>,
}

local function createPluginSettingsStore(
	plugin: Plugin,
	storageKey: string,
	defaultValue: PluginSettings?
): PluginSettingsStore
	local getStorage, setStorage = Signals.createSignal(if defaultValue then defaultValue else {} :: PluginSettings)

	local function readPluginSettingsAsync(): PluginSettings?
		print("loading...")
		local data = plugin:GetSetting(storageKey)

		if typeof(data) == "string" then
			local success, result = pcall(function()
				return HttpService:JSONDecode(data)
			end)

			if success then
				print("loaded!")
				return result
			end
		end
		print("nothing to load")
		return nil
	end

	local function writePluginSettingsAsync(storage: PluginSettings)
		print("saving...")
		local data = HttpService:JSONEncode(storage)
		if data then
			plugin:SetSetting(storageKey, data)
			print("saved!")
		end
	end

	task.spawn(function()
		local data = readPluginSettingsAsync()
		if data then
			setStorage(data)
		end
	end)

	local dispose = Signals.createEffect(function(scope)
		print("run effect")
		local storage = getStorage(scope)

		task.spawn(function()
			writePluginSettingsAsync(storage)
		end)
	end)

	return {
		get = getStorage,
		set = setStorage,
		dispose = dispose,
	}
end

return createPluginSettingsStore
