local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	name = "ReactPanelLayout",
	storyRoots = {
		script.Parent,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
	mapStory = function(Story)
		return function(props)
			return React.createElement(Foundation.FoundationProvider, {
				theme = Foundation.Enums.Theme.Dark,
				plugin = props.plugin,
				overlayGui = props.container,
			}, {
				Story = React.createElement(Story, props),
			})
		end
	end,
}
