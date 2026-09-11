local Foundation = require(script.Parent.Parent.Parent.Parent.RobloxPackages.Foundation)
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local BuilderIcons = require("./BuilderIcons")

return {
	controls = {
		filter = "",
		iconSize = {
			Foundation.Enums.InputSize.XSmall,
			Foundation.Enums.InputSize.Small,
			Foundation.Enums.InputSize.Medium,
			Foundation.Enums.InputSize.Large,
		} :: { Foundation.InputSize },
		iconVariant = {
			Foundation.Enums.IconVariant.Regular,
			Foundation.Enums.IconVariant.Filled,
		} :: { Foundation.IconVariant },
		showLabels = true,
	},
	story = function(props)
		return React.createElement(Foundation.FoundationProvider, {
			theme = props.theme,
		}, {
			ScrollView = React.createElement(Foundation.ScrollView, {
				tag = "size-full",
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromScale(1, 0),
					ScrollingDirection = Enum.ScrollingDirection.Y,
				},
				layout = {
					FillDirection = Enum.FillDirection.Vertical,
				},
			}, {
				BuilderIcons = React.createElement(BuilderIcons, {
					filter = props.controls.filter,
					iconSize = props.controls.iconSize,
					iconVariant = props.controls.iconVariant,
					showLabels = props.controls.showLabels,
				}),
			}),
		})
	end,
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
