local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Checkbox = require("@root/Forms/Checkbox")
local Dropdown = require("@root/Forms/Dropdown")
local InputField = require("@root/Forms/InputField")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState

local CHANGE_INDICATOR_WIDTH_PX = 2

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
			return React.createElement(Checkbox, {
				initialState = props.setting.value,
				onStateChange = setSetting,
			})
		elseif props.setting.settingType == "dropdown" then
			return React.createElement(Dropdown, {
				default = props.setting.choices[1].name,
				options = Sift.List.map(props.setting.choices, function(choice: SettingChoice)
					return choice.name
				end),
				onOptionChange = setSetting,
			})
		elseif props.setting.settingType == "number" then
			local range = props.setting.range

			return React.createElement(InputField, {
				placeholder = props.setting.value,
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

	local hasBeenChanged = not settingsContext.isSettingDefault(props.setting.name)

	local isEvenRow = if props.layoutOrder then props.layoutOrder % 2 == 0 else false

	return React.createElement(Foundation.View, {
		tag = {
			["size-full-0 auto-y row"] = true,
			["bg-surface-200"] = isEvenRow,
			["bg-surface-100"] = not isEvenRow,
		},
		LayoutOrder = props.layoutOrder,
	}, {
		ChangedIndicator = if hasBeenChanged
			then React.createElement(Foundation.View, {
				Size = UDim2.new(0, CHANGE_INDICATOR_WIDTH_PX, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = if isValid then theme.selection else theme.alert,
			})
			else nil,

		Main = React.createElement(Foundation.View, {
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = theme.padding,
			}),

			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.padding,
				PaddingRight = theme.paddingLarge,
				PaddingBottom = theme.padding,
				PaddingLeft = theme.paddingLarge,
			}),

			Info = React.createElement(Foundation.View, {
				LayoutOrder = nextLayoutOrder(),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Layout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = theme.paddingSmall,
				}),

				Name = React.createElement("TextLabel", {
					LayoutOrder = nextLayoutOrder(),
					Text = props.setting.displayName,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Font = theme.font,
					TextColor3 = theme.text,
					TextSize = theme.textSize,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}),

				Description = React.createElement("TextLabel", {
					LayoutOrder = nextLayoutOrder(),
					Text = props.setting.description,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Font = theme.font,
					TextColor3 = theme.textSubtitle,
					TextSize = theme.textSize,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
				}),
			}),

			OptionWrapper = React.createElement(Foundation.View, {
				LayoutOrder = nextLayoutOrder(),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1 / 2, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Option = optionElement,
			}),
		}),
	})
end

return SettingRow
