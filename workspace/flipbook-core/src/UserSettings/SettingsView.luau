local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local NavigationContext = require("@root/Navigation/NavigationContext")
local SettingRow = require("@root/UserSettings/SettingRow")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useMemo = React.useMemo

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

type SettingsGroup = {
	name: string,
	settings: { Setting },
}

local function SettingsView()
	local navigation = NavigationContext.use()
	local settingsByGroup: { SettingsGroup } = useMemo(function()
		local settings = Sift.Dictionary.values(defaultSettings)

		local sorted = Sift.Array.sort(settings, function(a: Setting, b: Setting)
			return a.name < b.name
		end)

		local groups = Sift.Array.reduce(sorted, function(accumulator: { [string]: SettingsGroup }, setting: Setting)
			local group: SettingsGroup
			if accumulator[setting.group] then
				group = accumulator[setting.group]
			else
				group = {
					name = setting.group,
					settings = {},
				}
				accumulator[setting.group] = group
			end

			table.insert(group.settings, setting)

			return accumulator
		end, {})

		return Sift.Array.sort(Sift.Dictionary.values(groups), function(a: SettingsGroup, b: SettingsGroup)
			return a.name < b.name
		end)
	end, { defaultSettings })

	local children: { [string]: React.Node } = {}
	for _, group in settingsByGroup do
		children[group.name] = React.createElement(Foundation.Text, {
			tag = "auto-xy text-heading-medium padding-medium",
			Text = group.name,
			LayoutOrder = nextLayoutOrder(),
		})

		for _, setting in group.settings do
			children[setting.name] = React.createElement(SettingRow, {
				setting = setting,
				layoutOrder = nextLayoutOrder(),
			})
		end
	end

	return React.createElement(Foundation.ScrollView, {
		tag = "size-full bg-surface-200 gap-large padding-y-large",
		scroll = {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.fromScale(1, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		},
		layout = {
			FillDirection = Enum.FillDirection.Vertical,
		},
	}, {
		Title = React.createElement(Foundation.View, {
			LayoutOrder = nextLayoutOrder(),
			tag = "align-y-center auto-y padding-right-medium row size-full-0",
		}, {
			Title = React.createElement(Foundation.Text, {
				LayoutOrder = nextLayoutOrder(),
				Text = "Settings",
				tag = "auto-y size-full-0 shrink text-align-x-left text-heading-large padding-medium",
			}),

			Close = React.createElement(Foundation.IconButton, {
				LayoutOrder = nextLayoutOrder(),
				icon = "x",
				isCircular = true,
				onActivated = function()
					navigation.navigateTo("Home")
				end,
				variant = Foundation.Enums.ButtonVariant.OverMedia,
			}),
		}),

		Settings = React.createElement(Foundation.View, {
			tag = "size-full shrink col gap-xlarge",
			LayoutOrder = nextLayoutOrder(),
		}, children),
	})
end

return SettingsView
