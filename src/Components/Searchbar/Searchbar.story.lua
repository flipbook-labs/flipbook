local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Searchbar = require(script.Parent)

return {
	summary = "Searchbar used to search for components",
	controls = {},
	story = Roact.createElement(Searchbar),
}
