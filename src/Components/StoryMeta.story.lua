local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local StoryMeta = require(script.Parent.StoryMeta)

return {
	story = React.createElement(StoryMeta, {
		story = {
			name = "Story",
			summary = "Story summary",
		},
	}),
}
