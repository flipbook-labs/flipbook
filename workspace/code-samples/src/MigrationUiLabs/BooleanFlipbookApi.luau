local Storyteller = require("@pkg/Storyteller")

local controls = {
	isVisible = Storyteller.createBooleanControl(true),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
