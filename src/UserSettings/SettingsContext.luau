local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local PluginSettingsStore = require("@root/Plugin/PluginSettingsStore")
local defaultSettings = require("./defaultSettings")

local useCallback = React.useCallback
local useState = React.useState
local useSignalState = SignalsReact.useSignalState

type Settings = defaultSettings.Settings

local Context = React.createContext({} :: SettingsContext)

export type Props = {
	children: React.Node?,
}

export type SettingsContext = {
	settings: Settings,

	getSetting: (settingName: string) -> any,
	getSettingDefault: (settingName: string) -> any,
	isSettingDefault: (settingName: string) -> boolean,
	setSetting: (settingName: string, newValue: any) -> (),
}

local function Provider(props: Props)
	local pluginSettingsStore = useSignalState(PluginSettingsStore.get)

	local userSettings: { [string]: any }, setUserSettings = useState(function()
		local existing = pluginSettingsStore.get(false).userSettings
		if typeof(existing) == "table" then
			return existing :: { [string]: any }
		else
			return {}
		end
	end)

	local loadSettingsFromDisk = useCallback(function()
		local settings = {}
		for settingName, setting in pairs(defaultSettings) do
			local savedValue = pluginSettingsStore.get(false).userSettings[settingName]

			settings[settingName] = Sift.Dictionary.join(setting, {
				value = savedValue,
			})
		end
		return settings
	end, { userSettings })

	local settings, setSettings = useState(function()
		return loadSettingsFromDisk()
	end)

	local getSettingDefault = useCallback(function(settingName: string)
		local setting = defaultSettings[settingName]
		if setting.settingType == "dropdown" then
			return setting.choices[1].name
		elseif setting.settingType == "checkbox" then
			return setting.value
		else
			return nil
		end
	end, {})

	local isSettingDefault = useCallback(function(settingName: string)
		local defaultValue = getSettingDefault(settingName)
		local savedValue = userSettings[settingName]

		return savedValue == nil or savedValue == defaultValue
	end, { userSettings, getSettingDefault } :: { unknown })

	local setSetting = useCallback(function(settingName: string, newValue: any)
		if newValue == nil then
			newValue = getSettingDefault(settingName)
		end

		setUserSettings(function(prev)
			return Sift.Dictionary.join(prev, {
				[settingName] = newValue,
			})
		end)

		setSettings(loadSettingsFromDisk)
	end, { loadSettingsFromDisk, getSettingDefault } :: { unknown })

	local getSetting = useCallback(function(settingName: string)
		return settings[settingName].value
	end, { settings })

	return React.createElement(Context.Provider, {
		value = {
			settings = settings,
			getSettingDefault = getSettingDefault,
			isSettingDefault = isSettingDefault,
			setSetting = setSetting,
			getSetting = getSetting,
		},
	}, props.children)
end

local function use(): SettingsContext
	return React.useContext(Context)
end

return {
	Context = Context,
	Provider = Provider,
	use = use,
}
