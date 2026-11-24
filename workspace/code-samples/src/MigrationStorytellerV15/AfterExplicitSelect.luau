local Storyteller = require("@pkg/Storyteller")

local controls = {
	size = Storyteller.createSelectControl({ "Small", "Medium", "Large" }, {
		default = "Small",
	}),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
