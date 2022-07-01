local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local NoStorySelected = require(script.Parent.NoStorySelected)

return {
	story = Roact.createElement(NoStorySelected),
}
