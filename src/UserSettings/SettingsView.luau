local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local ScrollingFrame = require("@root/Common/ScrollingFrame")
local SettingRow = require("@root/UserSettings/SettingRow")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useMemo = React.useMemo

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

local function SettingsView()
	local settingsContext = SettingsContext.use()
	local theme = useTheme()

	local orderedSettings: { Setting } = useMemo(function()
		local values = Sift.Dictionary.values(settingsContext.settings)
		return Sift.Array.sort(values, function(a: Setting, b: Setting)
			return a.name < b.name
		end)
	end, { settingsContext.settings })

	local children = {}
	for index, setting in orderedSettings do
		children[setting.name] = React.createElement(SettingRow, {
			setting = setting,
			layoutOrder = index,
		})
	end

	return React.createElement(ScrollingFrame, {
		BackgroundColor3 = theme.background,
		BackgroundTransparency = 0,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Title = React.createElement("TextLabel", {
			LayoutOrder = nextLayoutOrder(),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.headerFont,
			Size = UDim2.fromScale(0, 0),
			Text = "Settings",
			TextColor3 = theme.text,
			TextSize = theme.headerTextSize,
		}, {
			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.paddingLarge,
				PaddingRight = theme.paddingLarge,
				PaddingBottom = theme.paddingLarge,
				PaddingLeft = theme.paddingLarge,
			}),
		}),

		Settings = React.createElement("Frame", {
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = theme.padding,
			}),
		}, children),
	})
end

return SettingsView
