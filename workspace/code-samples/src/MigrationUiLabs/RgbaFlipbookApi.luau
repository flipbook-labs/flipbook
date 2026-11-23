local Storyteller = require("@pkg/Storyteller")

local controls = {
	frameColor = Storyteller.createColorControl(Color3.new(1, 1, 1)),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
