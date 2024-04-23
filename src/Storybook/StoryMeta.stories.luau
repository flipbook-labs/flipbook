local React = require("@pkg/React")
local StoryMeta = require("@root/Storybook/StoryMeta")

local stories = {}

stories.Primary = React.createElement(StoryMeta, {
	story = {
		name = "Story",
		summary = "Story summary",
	},
})

return {
	stories = stories,
}
