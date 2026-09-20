local Roact = require("@pkg/Roact")

local HelloWorldLabel = require("./HelloWorldLabel")

return {
	story = function()
		return Roact.createElement(HelloWorldLabel, {
			name = "Flipbook",
		})
	end,
}
