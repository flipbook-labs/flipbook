local Storyteller = require("@pkg/Storyteller")

local controls = {
	count = Storyteller.createNumberControl(1, NumberRange.new(0, 100), 1),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
