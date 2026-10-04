local Storyteller = require("@pkg/Storyteller")

local controls: Storyteller.StoryControlsSchema = {
	label = Storyteller.createStringControl("Hello"),
	count = Storyteller.createNumberControl(5),
	isVisible = Storyteller.createBooleanControl(true),
	size = Storyteller.createSelectControl({ "Small", "Medium", "Large" }, {
		default = "Small",
	}),
	alignment = Storyteller.createSelectControl({ "Left", "Center", "Right" }, {
		default = "Left",
	}),
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
