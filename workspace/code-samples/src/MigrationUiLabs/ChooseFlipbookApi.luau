local Storyteller = require("@pkg/Storyteller")

local controls = {
	theme = Storyteller.createSelectControl({ "Dark", "Light" }),
	size = Storyteller.createSelectControl({ "Small", "Medium", "Large" }, {
		default = "Medium",
	}),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
