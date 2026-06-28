local Storyteller = require("@pkg/Storyteller")

local controls = {
	tint = Storyteller.createColorControl(Color3.fromRGB(255, 0, 0)),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
