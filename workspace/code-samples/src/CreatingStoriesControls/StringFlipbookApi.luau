local Storyteller = require("@pkg/Storyteller")

local controls = {
	label = Storyteller.createStringControl("Click Me"),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
