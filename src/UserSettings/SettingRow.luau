local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local Checkbox = require("@root/Forms/Checkbox")
local Dropdown = require("@root/Forms/Dropdown")
local InputField = require("@root/Forms/InputField")
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
		if props.setting.settingType == "checkbox" then
			return React.createElement(Checkbox, {
				initialState = userSettings[props.setting.name],
				onStateChange = setSetting,
			})
		elseif props.setting.settingType == "dropdown" then
			local initialChoiceIndex = Sift.List.findWhere(props.setting.choices, function(choice: SettingChoice)
				return choice.name == userSettings[props.setting.name]
			end) or 1
			return React.createElement(Dropdown, {
				default = props.setting.choices[initialChoiceIndex].name,
				options = Sift.List.map(props.setting.choices, function(choice: SettingChoice)
					return choice.name
				end),
				onOptionChange = setSetting,
			})
		elseif props.setting.settingType == "number" then
			local range = props.setting.range

			return React.createElement(InputField, {
				placeholder = userSettings[props.setting.name],
				onSubmit = function(newValue, isValidOnSubmit)
					if newValue == "" then
						setSetting(nil)
					else
						setIsValid(isValidOnSubmit)
						setSetting(tonumber(newValue))
					end
				end,
				validate = function(text)
					local n = tonumber(text)
					if n == nil then
						return false
					end

					if range then
						if n < range.Min or n > range.Max then
							return false
						end
					end

					return true
				end,
			})
		end
		error(`no handling for setting type {props.setting.settingType}`)
	end, { props.setting, setSetting } :: { unknown })

	local hasBeenChanged = not userSettingsStore.isSettingDefault(props.setting.name)

	local isEvenRow = if props.layoutOrder then props.layoutOrder % 2 == 0 else false

	return React.createElement(Foundation.View, {
		tag = {
			["size-full-0 auto-y radius-medium"] = true,
			["bg-surface-200"] = isEvenRow,
			["bg-surface-100"] = not isEvenRow,
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
			Info = React.createElement(Foundation.View, {
				tag = "size-full-0 auto-y col gap-small",
				LayoutOrder = nextLayoutOrder(),
			}, {
				Name = React.createElement(Foundation.Text, {
					tag = "auto-xy text-title-medium truncate",
					Text = props.setting.displayName,
					LayoutOrder = nextLayoutOrder(),
				}),

				Description = React.createElement(Foundation.Text, {
					tag = "auto-xy text-body-small text-wrap text-align-x-left",
					Text = props.setting.description,
					LayoutOrder = nextLayoutOrder(),
				}),
			}),

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
