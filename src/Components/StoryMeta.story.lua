local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local StoryMeta = require(script.Parent.StoryMeta)

local e = Roact.createElement

return {
	story = e(StoryMeta, {
		story = {
			name = "Sample.story",
			summary = "A summary of the current story",
		},
		storyModule = script.Parent,
		storyParent = workspace,
	}),
}
