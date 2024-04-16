local flipbook = script:FindFirstAncestor("flipbook")

local NoStorySelected = require(script.Parent.NoStorySelected)
local React = require(flipbook.Packages.React)

local stories = {}

stories.Primary = React.createElement(NoStorySelected)

return {
	stories = stories,
}
