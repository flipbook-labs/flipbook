local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Searchbar = require(script.Parent.Searchbar)

return {
	summary = "Searchbar used to search for components",
	controls = {},
	story = React.createElement(Searchbar),
}
