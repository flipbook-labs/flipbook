local Storyteller = require("@pkg/Storyteller")

local controls = {
	opacity = Storyteller.createSliderControl(1, NumberRange.new(0, 1), 0.01),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
