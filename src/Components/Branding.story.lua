local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Branding = require(script.Parent.Branding)

return {
	summary = "Icon and Typography for flipbook",
	controls = {},
	story = Roact.createElement(Branding),
}
