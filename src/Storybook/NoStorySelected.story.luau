local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local NoStorySelected = require(script.Parent.NoStorySelected)

return {
	story = React.createElement(NoStorySelected),
}
