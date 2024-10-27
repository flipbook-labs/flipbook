local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryMeta = require("@root/Storybook/StoryMeta")

return {
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new() :: any,
	}, {
		StoryMeta = React.createElement(StoryMeta, {
			story = {
				name = "Story",
				summary = "Story summary",
				source = Instance.new("ModuleScript"),
				storybook = {
					storyRoots = {},
				},
			},
		}),
	}),
}
