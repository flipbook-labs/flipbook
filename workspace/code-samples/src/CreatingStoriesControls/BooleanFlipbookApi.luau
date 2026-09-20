local Storyteller = require("@pkg/Storyteller")

local controls = {
	isDisabled = Storyteller.createBooleanControl(false),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
