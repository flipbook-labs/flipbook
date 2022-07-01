local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Brand = require(script.Parent.Brand)

return {
	summary = "Icon and Typography for flipbook",
	controls = {},
	story = Roact.createElement(Brand),
}
