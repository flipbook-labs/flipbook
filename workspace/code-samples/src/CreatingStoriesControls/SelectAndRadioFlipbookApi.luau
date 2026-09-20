local Storyteller = require("@pkg/Storyteller")

local controls = {
	size = Storyteller.createSelectControl({ "Small", "Medium", "Large" }, {
		default = "Medium",
	}),
	alignment = Storyteller.createRadioControl({ "Left", "Center", "Right" }),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
