local Storyteller = require("@pkg/Storyteller")

local controls = {
	greeting = Storyteller.createStringControl("Hello, World!"),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
