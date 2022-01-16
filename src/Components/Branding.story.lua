local Roact = require(script.Parent.Parent.Packages.Roact)
local Branding = require(script.Parent.Branding)

return {
	roact = Roact,
	story = Roact.createFragment({
		brandSm = Roact.createElement(Branding, {
			anchorPoint = Vector2.new(0.5, 0),
			position = UDim2.fromScale(0.5, 0),
			size = 20,
		}),

		brandMd = Roact.createElement(Branding, {
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.5, 0.5),
			size = 24,
		}),

		brandLg = Roact.createElement(Branding, {
			anchorPoint = Vector2.new(0.5, 1),
			position = UDim2.fromScale(0.5, 1),
			size = 32,
		}),
	}),
}
