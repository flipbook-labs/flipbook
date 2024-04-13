local Example = script:FindFirstAncestor("Example")

local Button = require(script.Parent.Button)
local Roact = require(Example.Parent.Packages.Roact)

return {
	summary = "A generic button component that can be used anywhere",
	roact = Roact,
	story = Roact.createElement(Button, {
		text = "Click me",
		onActivated = function()
			print("click")
		end,
	}),
}
