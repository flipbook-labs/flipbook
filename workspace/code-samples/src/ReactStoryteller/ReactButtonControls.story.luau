local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ReactButton = require("./ReactButton")

local controls: Storyteller.StoryControlsSchema = {
	text = Storyteller.createStringControl("Click Me"),
	isDisabled = Storyteller.createBooleanControl(false),
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(props)
		return React.createElement(ReactButton, {
			text = props.controls.text,
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
