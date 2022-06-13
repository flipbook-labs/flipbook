local flipbook = script:FindFirstAncestor("flipbook")

local Sidebar = require(flipbook.Components.Sidebar)
local Roact = require(flipbook.Packages.Roact)

return {
	summary = "Sidebar containing brand, searchbar, and component tree",
	controls = {},
	story = Roact.createElement(Sidebar),
}
