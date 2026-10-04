local Storyteller = require("@pkg/Storyteller")

local controls = {
	volume = Storyteller.createSliderControl(50, NumberRange.new(0, 100), 1),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
