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
	local isInitializing = false

	local function readPluginSettingsAsync(plugin: Plugin): T?
		logger:Info(`reading plugin settings for {storageKey} from disk...`)

		local data
		local success, err = pcall(function()
			data = plugin:GetSetting(storageKey)
		end)

		if success then
			logger:Info(`read raw plugin settings for {storageKey}:`, data)
		else
			logger:Warn(`failed to read plugin settings for {storageKey}: {err}`)
			setErr(err)
			return nil
		end

		if typeof(data) == "string" then
			logger:Info(`deserializing plugin settings for {storageKey} to object...`)

			local json
			success, err = pcall(function()
				json = HttpService:JSONDecode(data)
			end)

			if not success then
				logger:Warn(`failed to load plugin settings for {storageKey}: {err}`)
				setErr(err)
				return nil
			end

			success, err = validate(json)

			if not success then
				logger:Warn(`plugin settings are malformed for {storageKey}: {err}`)
				setErr(err)
				return nil
			end

			logger:Info(`got plugin settings for {storageKey}:`, json)

			return json
		end

		logger:Info("no plugin settings to read")

		return nil
	end

	local function writePluginSettingsAsync(plugin: Plugin, storage: T)
		logger:Info("writing plugin settings to disk...")
		local data
		local success, err = pcall(function()
			data = HttpService:JSONEncode(storage)
		end)

		if success then
			logger:Info(`parsed storage value into JSON: {data}`)
		else
			logger:Warn(`failed to parse storage value into JSON: {err}`)
			setErr(err)
			return
		end

		if data then
			success, err = pcall(function()
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
			if getIsLoading(scope) and not isInitializing then
				isInitializing = true

				task.spawn(function()
					local data = readPluginSettingsAsync(plugin)

					if data then
						setStorage(data)
					end

					logger:Debug("finished loading plugin settings")
					setIsLoading(false)
					isInitializing = false
				end)
			end

			if storage ~= prevStorage and not getIsLoading(scope) then
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
