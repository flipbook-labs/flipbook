local Roact = require(script.Parent.Parent.Packages.Roact)
local Button = require(script.Parent.Button)

return {
	roact = Roact,
	story = Roact.createElement(Button, {
		text = "Click me",
	}),
}
