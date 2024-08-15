local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryMeta = require("@root/Storybook/StoryMeta")

local stories = {}

stories.Primary = React.createElement(ContextProviders, {
	plugin = MockPlugin.new(),
}, {
	StoryMeta = React.createElement(StoryMeta, {
		story = {
			name = "Story",
			summary = "Story summary",
		},
	}),
})

return {
	stories = stories,
}
