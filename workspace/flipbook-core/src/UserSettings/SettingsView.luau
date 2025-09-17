local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local SettingRow = require("@root/UserSettings/SettingRow")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useMemo = React.useMemo

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

local function SettingsView()
	local orderedSettings: { Setting } = useMemo(function()
		local values = Sift.Dictionary.values(defaultSettings)
		return Sift.Array.sort(values, function(a: Setting, b: Setting)
			return a.name < b.name
		end)
	end, { defaultSettings })

	local children: { [string]: React.Node } = {}
	for index, setting in orderedSettings do
		children[setting.name] = React.createElement(SettingRow, {
			setting = setting,
			layoutOrder = index,
		})
	end

	return React.createElement(Foundation.ScrollView, {
		tag = "size-full col bg-surface-200 gap-large padding-y-large",
		scroll = {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.fromScale(1, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		},
	}, {
		Title = React.createElement(Foundation.Text, {
			tag = "auto-xy text-heading-large padding-medium",
			Text = "Settings",
			LayoutOrder = nextLayoutOrder(),
		}),

		Settings = React.createElement(Foundation.View, {
			tag = "size-full-0 auto-y col gap-medium",
			LayoutOrder = nextLayoutOrder(),
		}, children),
	})
end

return SettingsView
