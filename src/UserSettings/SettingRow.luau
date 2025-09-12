local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local SettingsContext = require("@root/UserSettings/SettingsContext")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

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
	local settingsContext = SettingsContext.use()
	local isValid, setIsValid = useState(true)

	local setSetting = useCallback(function(newValue: any)
		settingsContext.setSetting(props.setting.name, newValue)
	end, { settingsContext.setSetting, props.setting } :: { unknown })

	local optionElement = useMemo(function(): React.Node
		if props.setting.settingType == "checkbox" then
			return React.createElement(Foundation.Checkbox, {
				label = props.setting.displayName,
				hint = props.setting.description,
				hasError = not isValid,
				isChecked = props.setting.value,
				onActivated = setSetting,
			})
		elseif props.setting.settingType == "dropdown" then
			return React.createElement(Foundation.Dropdown.Root, {
				label = props.setting.displayName,
				hint = props.setting.description,
				hasError = not isValid,
				value = props.setting.choices[1].name,
				items = Sift.List.map(props.setting.choices, function(choice: SettingChoice)
					return choice.name
				end),
				onItemChanged = setSetting,
			})
		elseif props.setting.settingType == "number" then
			local range = props.setting.range

			return React.createElement(Foundation.NumberInput, {
				value = props.setting.value,
				label = props.setting.displayName,
				hint = props.setting.description,
				hasError = not isValid,
				maximum = if range then range.Max else nil,
				minimum = if range then range.Min else nil,
				onChanged = setSetting,
			})
		end
		error(`no handling for setting type {props.setting.settingType}`)
	end, { props.setting, setSetting } :: { unknown })

	local hasBeenChanged = not settingsContext.isSettingDefault(props.setting.name)

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

		Main = React.createElement(Foundation.View, {
			tag = "size-full-0 auto-y col gap-medium padding-medium",
		}, {
			-- Info = React.createElement(Foundation.View, {
			-- 	tag = "size-full-0 auto-y col gap-small",
			-- 	LayoutOrder = nextLayoutOrder(),
			-- }, {
			-- 	Name = React.createElement(Foundation.Text, {
			-- 		tag = "auto-xy text-title-medium truncate",
			-- 		Text = props.setting.displayName,
			-- 		LayoutOrder = nextLayoutOrder(),
			-- 	}),

			-- 	Description = React.createElement(Foundation.Text, {
			-- 		tag = "auto-xy text-body-small text-wrap text-align-x-left",
			-- 		Text = props.setting.description,
			-- 		LayoutOrder = nextLayoutOrder(),
			-- 	}),
			-- }),

			OptionWrapper = React.createElement(Foundation.View, {
				tag = "size-full-0 auto-y",
				LayoutOrder = nextLayoutOrder(),
			}, {
				Option = optionElement,
			}),
		}),
	})
end

return SettingRow
