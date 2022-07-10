local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local StoryMeta = require(script.Parent.StoryMeta)

return {
	story = Roact.createElement(StoryMeta, {
		story = {
			name = "Story",
			summary = "Story summary",
		},
	}),
}
