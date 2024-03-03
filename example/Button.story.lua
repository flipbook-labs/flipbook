local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)
local Button = require("./Button")

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
