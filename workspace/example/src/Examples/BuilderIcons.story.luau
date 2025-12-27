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
		},
		showLabels = true,
	},
	story = function(props)
		return React.createElement(Foundation.FoundationProvider, {
			theme = props.theme,
		}, {
			BuilderIcons = React.createElement(BuilderIcons, {
				filter = props.controls.filter,
				iconSize = props.controls.iconSize,
				showLabels = props.controls.showLabels,
			}),
		})
	end,
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
