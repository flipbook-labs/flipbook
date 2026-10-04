local Storyteller = require("@pkg/Storyteller")

local controls = {
	tags = Storyteller.createMultiSelectControl({ "New", "Featured", "Sale" }, {
		default = { "New" },
	}),
	options = Storyteller.createCheckControl({ "Bold", "Italic", "Underline" }),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
