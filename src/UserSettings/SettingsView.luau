local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local SettingRow = require("@root/UserSettings/SettingRow")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local defaultSettings = require("@root/UserSettings/defaultSettings")
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
