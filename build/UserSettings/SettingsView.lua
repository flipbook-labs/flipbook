local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)
local Sift = require(script.Parent.Parent.Packages.Sift)

local NavigationContext = require(script.Parent.Parent.Navigation.NavigationContext)
local SettingRow = require(script.Parent.SettingRow)
local defaultSettings = require(script.Parent.defaultSettings)
local nextLayoutOrder = require(script.Parent.Parent.Common.nextLayoutOrder)

local useMemo = React.useMemo

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

local function SettingsView()
	local navigation = NavigationContext.use()
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
			tag = "size-full-0 auto-y col gap-xlarge",
			LayoutOrder = nextLayoutOrder(),
		}, children),
	})
end

return SettingsView
