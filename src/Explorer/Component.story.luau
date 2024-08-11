local React = require("@pkg/React")

local Component = require("./Component")
local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local childNode1 = {
	name = "Button",
	icon = "story",
}

local childNode2 = {
	name = "Toggle",
	icon = "story",
}

local childNode3 = {
	name = "Radio",
	icon = "story",
}

local directoryNode1 = {
	name = "Files",
	icon = "folder",
	children = {
		childNode1,
		childNode2,
		childNode3,
	},
}

local storybookNode = {
	name = "Storybook",
	icon = "storybook",
	children = {
		directoryNode1,
	},
}

return {
	summary = "Component as storybook with children",
	controls = {},
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new(),
	}, {
		Component = React.createElement(Component, {
			activeNode = nil,
			node = storybookNode,
			onClick = function() end,
		}),
	}),
}
