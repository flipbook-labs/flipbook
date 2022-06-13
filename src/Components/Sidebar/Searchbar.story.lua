local flipbook = script:FindFirstAncestor("flipbook")

local Searchbar = require(flipbook.Components.Sidebar.Searchbar)
local Roact = require(flipbook.Packages.Roact)

return {
	summary = "Searchbar used to search for components",
	controls = {},
	story = Roact.createElement(Searchbar),
}
