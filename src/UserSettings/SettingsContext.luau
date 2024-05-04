local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local PluginContext = require("@root/Plugin/PluginContext")
local defaultSettings = require("./defaultSettings")

local useCallback = React.useCallback
local useContext = React.useContext
local useMemo = React.useMemo
local useState = React.useState

type Settings = defaultSettings.Settings

local Context = React.createContext({})

export type Props = {
	children: React.Node?,
}

export type SettingsContext = {
	settings: Settings,
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

	local setSetting = useCallback(function(settingName: string, newValue: any)
		plugin:SetSetting(settingName, newValue)
		setSettings(loadSettingsFromDisk)
	end, { plugin })

	local context: SettingsContext = useMemo(function()
		return {
			settings = settings,
			setSetting = setSetting,
		}
	end, { settings })

	return React.createElement(Context.Provider, {
		value = context,
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
