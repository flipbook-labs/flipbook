local Roact = require("@pkg/Roact")

local RoactButton = require("./RoactButton")

return {
	story = function()
		return Roact.createElement(RoactButton, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
