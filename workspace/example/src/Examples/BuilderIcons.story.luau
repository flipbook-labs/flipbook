local Foundation = require(script.Parent.Parent.Parent.Parent.RobloxPackages.Foundation)
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local BuilderIcons = require("./BuilderIcons")

return {
	controls = {
		filter = "",
	},
	story = function(props)
		return React.createElement(Foundation.FoundationProvider, {
			theme = props.theme,
		}, {
			BuilderIcons = React.createElement(BuilderIcons, {
				filter = props.controls.filter,
			}),
		})
	end,
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
