local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ReactButtonControls = require("./ReactButtonControls")

local controls: Storyteller.StoryControlsSchema = {
	text = "Click Me",
	isDisabled = false,
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(props)
		return React.createElement(ReactButtonControls, {
			text = props.controls.text,
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
