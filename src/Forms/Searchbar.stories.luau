local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Searchbar = require(script.Parent.Searchbar)

local stories = {}

stories.Primary = React.createElement(Searchbar)

return {
	summary = "Searchbar used to search for components",
	controls = {},
	stories = stories,
}
