local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local NoStorySelected = require(script.Parent.NoStorySelected)

local stories = {}

stories.Primary = React.createElement(NoStorySelected)

return {
	stories = stories,
}
