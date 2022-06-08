local Branding = require(script.Parent.Branding)
local Roact = require(script.Parent.Parent.Packages.Roact)

return {
	story = Roact.createElement(Branding, {
		position = UDim2.fromOffset(20, 20),
		size = 24,
	}),
	roact = Roact,
}
