local Storyteller = require("@pkg/Storyteller")

local controls: Storyteller.StoryControlsSchema = {
	greeting = Storyteller.createStringControl("Hello, World!"),
	isVisible = Storyteller.createBooleanControl(true),
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(props)
		local label = Instance.new("TextLabel")
		label.Text = props.controls.greeting
		label.Visible = props.controls.isVisible
		return label
	end,
}

return story
