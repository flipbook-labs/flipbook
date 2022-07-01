local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Sidebar = require(script.Parent.Sidebar)

return {
	summary = "Sidebar containing brand, searchbar, and component tree",
	controls = {},
	story = Roact.createElement(Sidebar),
}
