local flipbook = script:FindFirstAncestor("flipbook")

local NoStorySelected = require(script.Parent.NoStorySelected)
local React = require(flipbook.Packages.React)

return {
	story = React.createElement(NoStorySelected),
}
