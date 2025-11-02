local HttpService = game:GetService("HttpService")

local Signals = require("@rbxpkg/Signals")

local PluginStore = require("@root/Plugin/PluginStore")
local logger = require("@root/logger")

export type PluginSettingsStore<T> = {
	getStorage: Signals.getter<T>,
	setStorage: Signals.setter<T>,

	isSettingDefault: (settingName: string) -> boolean,

	getIsLoading: Signals.getter<boolean>,
	getErr: Signals.getter<string?>,

	dispose: () -> (),
}

--[[
	Creates a store to manage plugin settings.

	Settings are persisted using Plugin:SetSetting and Plugin:GetSetting, and are
	stored as JSON strings. The settings are loaded once when the store is first
	created, and any changes to the settings are automatically saved.
]]
local function createPluginSettingsStore<T>(
	storageKey: string,
	defaultValue: T,
	validate: (value: any) -> (boolean, string)
): PluginSettingsStore<T>
	local getStorage, setStorage = Signals.createSignal(defaultValue)
	local getIsLoading, setIsLoading = Signals.createSignal(true)
	local getErr, setErr = Signals.createSignal(nil :: string?)

	local function readPluginSettingsAsync(plugin: Plugin): T?
		logger:Info(`reading plugin settings for {storageKey} from disk...`)

		local data = plugin:GetSetting(storageKey)

		logger:Debug(`read raw plugin settings for {storageKey}:`, data)

		if typeof(data) == "string" then
			logger:Info(`deserializing plugin settings for {storageKey} to object...`)

			local success, result = pcall(function()
				return HttpService:JSONDecode(data)
			end)

			if not success then
				logger:Warn(`failed to load plugin settings for {storageKey}:`, result)
				setErr(result)
				return nil
			end

			local isValid, message = validate(result)

			if not isValid then
				logger:Warn(`plugin settings are malformed for {storageKey}:`, message)
				setErr(message)
				return nil
			end

			logger:Info(`got plugin settings for {storageKey}:`, result)

			return result
		end

		logger:Info("no plugin settings to read")

		return nil
	end

	local function writePluginSettingsAsync(plugin: Plugin, storage: T)
		logger:Info("writing plugin settings to disk...")
		local data = HttpService:JSONEncode(storage)

		if data then
			local success, err = pcall(function()
				plugin:SetSetting(storageKey, data)
			end)

			if success then
				logger:Info(`wrote plugin settings to disk: {data}`)
			else
				logger:Warn(`failed to write plugin settings to disk: {err}`)
			end
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
					logger:Debug("finished loading plugin settings")
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
