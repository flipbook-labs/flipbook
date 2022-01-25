local Roact = require(script.Parent.Parent.Roact)
local Button = require(script.Parent.Button)

return {
	summary = "A generic button component that can be used anywhere",
	story = Roact.createElement(Button, {
		text = "Click me",
		onActivated = function()
			print("click")
		end,
	}),
}
