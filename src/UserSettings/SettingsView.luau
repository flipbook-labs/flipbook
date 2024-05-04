local React = require("@pkg/React")

local SettingRow = require("@root/UserSettings/SettingRow")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local useTheme = require("@root/Common/useTheme")

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

local function SettingsView()
	local settingsContext = SettingsContext.use()
	local theme = useTheme()

	local children = {}
	local index = 0
	for _, setting: Setting in settingsContext.settings do
		index += 1
		children[setting.name] = React.createElement(SettingRow, {
			setting = setting,
			layoutOrder = index,
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = theme.padding,
		}),
	}, children)
end

return SettingsView
