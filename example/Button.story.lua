local Roact = require("@pkg/Roact")
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
