local flipbook = script:FindFirstAncestor("flipbook")

local Brand = require(flipbook.Components.Sidebar.Brand)
local Roact = require(flipbook.Packages.Roact)

return {
	summary = "Icon and Typography for flipbook",
	controls = {},
	story = Roact.createElement(Brand),
}
