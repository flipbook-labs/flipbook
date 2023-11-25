local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local StoryMeta = require(flipbook.Storybook.StoryMeta)

return {
	story = React.createElement(StoryMeta, {
		story = {
			name = "Story",
			summary = "Story summary",
		},
	}),
}
