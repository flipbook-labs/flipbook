local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Checkbox = require("@root/Forms/Checkbox")
local Dropdown = require("@root/Forms/Dropdown")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useCallback = React.useCallback
local useMemo = React.useMemo

local CHANGE_INDICATOR_WIDTH_PX = 2

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

export type Props = {
	setting: Setting,
	layoutOrder: number?,
}

local function SettingRow(props: Props)
	local settingsContext = SettingsContext.use()
	local theme = useTheme()

	local setSetting = useCallback(function(newValue: any)
		settingsContext.setSetting(props.setting.name, newValue)
	end, { settingsContext.setSetting, props.setting })

	local optionElement = useMemo(function()
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
		end
		error(`no handling for setting type {props.setting.settingType}`)
	end, { props.setting, setSetting })

	local hasBeenChanged = not settingsContext.isSettingDefault(props.setting.name)

	return React.createElement("Frame", {
		BorderSizePixel = 0,
		BackgroundColor3 = if props.layoutOrder and props.layoutOrder % 2 == 0 then theme.sidebar else theme.background,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		ChangedIndicator = if hasBeenChanged
			then React.createElement("Frame", {
				Size = UDim2.new(0, CHANGE_INDICATOR_WIDTH_PX, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = theme.selection,
			})
			else nil,

		Main = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = theme.padding,
			}),

			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.paddingSmall,
				PaddingRight = theme.padding,
				PaddingBottom = theme.paddingSmall,
				PaddingLeft = theme.padding,
			}),

			Info = React.createElement("Frame", {
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
				}),
			}),

			OptionWrapper = React.createElement("Frame", {
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
