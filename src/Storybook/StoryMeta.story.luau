local React = require("@pkg/React")
local StoryMeta = require("@root/Storybook/StoryMeta")

return {
	story = React.createElement(StoryMeta, {
		story = {
			name = "Story",
			summary = "Story summary",
		},
	}),
}
