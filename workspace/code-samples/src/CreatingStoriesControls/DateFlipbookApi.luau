local Storyteller = require("@pkg/Storyteller")

local controls = {
	publishedAt = Storyteller.createDateControl(),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
