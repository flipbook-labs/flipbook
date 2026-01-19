local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

return {
	name = "FlipbookCore",
	storyRoots = {
		script.Parent,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
	mapStory = function(Story)
		return function(props)
			return React.createElement(ContextProviders, {
				plugin = MockPlugin.new(),
				overlayGui = props.container,
			}, {
				Story = React.createElement(Story, props),
			})
		end
	end,
}
