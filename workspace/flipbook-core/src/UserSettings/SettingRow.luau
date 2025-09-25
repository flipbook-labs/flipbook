local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useSignalState = SignalsReact.useSignalState
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

export type Props = {
	setting: Setting,
	layoutOrder: number?,
}

local function SettingRow(props: Props)
	local theme = useTheme()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local isValid, setIsValid = useState(true)

	local setSetting = useCallback(function(newValue: any)
		userSettingsStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				[props.setting.name] = newValue,
			})
		end)
	end, { userSettingsStore.setStorage, props.setting } :: { unknown })

	local optionElement = useMemo(function(): React.Node
		local value = userSettings[props.setting.name]

		if props.setting.settingType == "checkbox" then
			return React.createElement(Foundation.Checkbox, {
				label = props.setting.displayName,
				hint = props.setting.description,
				isChecked = value,
				onActivated = setSetting,
			})
		elseif props.setting.settingType == "dropdown" then
			local items = Sift.List.map(props.setting.choices, function(choice: SettingChoice): Foundation.MenuItem
				return {
					id = choice.name,
					text = choice.name,
				}
			end)

			return React.createElement(Foundation.Dropdown.Root, {
				label = props.setting.displayName,
				hint = props.setting.description,
				hasError = not isValid,
				value = value,
				items = items,
				onItemChanged = setSetting,
			})
		elseif props.setting.settingType == "number" then
			local range = props.setting.range

			return React.createElement(Foundation.NumberInput, {
				value = value,
				label = props.setting.displayName,
				hint = props.setting.description,
				hasError = not isValid,
				step = 10,
				maximum = if range then range.Max else nil,
				minimum = if range then range.Min else nil,
				onChanged = setSetting,
			})
		end
		error(`no handling for setting type {props.setting.settingType}`)
	end, { props.setting, userSettings } :: { unknown })

	local hasBeenChanged = not userSettingsStore.isSettingDefault(props.setting.name)

	return React.createElement(Foundation.View, {
		tag = {
			["size-full-0 auto-y radius-medium"] = true,
		},
		LayoutOrder = props.layoutOrder,
	}, {
		ChangedIndicator = if hasBeenChanged
			then React.createElement(Foundation.View, {
				tag = "size-50-full",
				backgroundStyle = {
					Color3 = if isValid then theme.selection else theme.alert,
					Transparency = 0,
				},
			})
			else nil,

		Option = optionElement,
	})
end

return SettingRow
