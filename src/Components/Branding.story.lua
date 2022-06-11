local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Branding = require(script.Parent.Branding)

return {
	story = Roact.createElement(Branding, {
		position = UDim2.fromOffset(20, 20),
		size = 24,
	}),
}
