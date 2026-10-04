local Storyteller = require("@pkg/Storyteller")

local controls: Storyteller.StoryControlsSchema = {
	label = Storyteller.createStringControl("Click Me"),
	isDisabled = Storyteller.createBooleanControl(false),
}

local story: Storyteller.Story<any> = {
	summary = "A basic button component.",
	controls = controls,
	story = function(props)
		local button = Instance.new("TextButton")
		button.Text = props.controls.label
		button.Active = not props.controls.isDisabled
		return button
	end,
}

return story
