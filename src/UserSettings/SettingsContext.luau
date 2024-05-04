local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local PluginContext = require("@root/Plugin/PluginContext")
local defaultSettings = require("./defaultSettings")

local useCallback = React.useCallback
local useContext = React.useContext
local useState = React.useState

type Settings = defaultSettings.Settings

local Context = React.createContext({})

export type Props = {
	children: React.Node?,
}

export type SettingsContext = {
	settings: Settings,

	getSettingDefault: (settingName: string) -> any,
	isSettingDefault: (settingName: string) -> boolean,
	setSetting: (settingName: string, newValue: any) -> (),
}

local function Provider(props: Props)
	local plugin = useContext(PluginContext.Context)

	local loadSettingsFromDisk = useCallback(function()
		local settings = {}
		for settingName, setting in defaultSettings do
			local savedValue = plugin:GetSetting(settingName)

			settings[settingName] = Sift.Dictionary.join(setting, {
				value = savedValue,
			})
		end
		return settings :: Settings
	end, { plugin })

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
		local savedValue = plugin:GetSetting(settingName)

		return savedValue == nil or savedValue == defaultValue
	end, { plugin, getSettingDefault })

	local setSetting = useCallback(function(settingName: string, newValue: any)
		plugin:SetSetting(settingName, newValue)
		setSettings(loadSettingsFromDisk)
	end, { plugin })

	return React.createElement(Context.Provider, {
		value = {
			settings = settings,
			getSettingDefault = getSettingDefault,
			isSettingDefault = isSettingDefault,
			setSetting = setSetting,
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
