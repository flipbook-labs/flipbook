local HelloWorld = require(script.Parent.HelloWorld)
local Roact = require(script.Parent.Parent.Roact)

return {
	story = function()
		return Roact.createElement(HelloWorld, {
			name = "Flipbook",
		})
	end,
}
