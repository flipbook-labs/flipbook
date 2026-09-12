local Storyteller = require("@pkg/Storyteller")

local controls: Storyteller.StoryControlsSchema = {
	label = Storyteller.createStringControl("Click Me"),
	isDisabled = Storyteller.createBooleanControl(false),
	size = Storyteller.createSelectControl({ "Small", "Medium", "Large" }, {
		default = "Medium",
	}),
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextButton")
	end,
}

return story
