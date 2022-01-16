local Roact = require(script.Parent.Parent.Packages.Roact)
local Icon = require(script.Parent.Icon)

return {
	roact = Roact,
	story = Roact.createElement(Icon, {
		icon = "magnifying-glass",
		position = UDim2.fromScale(0.5, 0.5),
		size = 32,
	}),
}
