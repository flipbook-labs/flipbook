local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local StoryControls = require(script.Parent.StoryControls)

return {
	summary = "Panel for configuring the controls of a story",
	story = Roact.createElement(StoryControls, {
		controls = {
			foo = "bar",
			checkbox = false,
			dropdown = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
		},
	}),
}
