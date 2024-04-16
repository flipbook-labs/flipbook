local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local StoryMeta = require(flipbook.Storybook.StoryMeta)

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
