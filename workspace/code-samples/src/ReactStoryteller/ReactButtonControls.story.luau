local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ReactButton = require("./ReactButton")

local controls: Storyteller.StoryControlsSchema = {
	text = "Click Me",
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(props)
		return React.createElement(ReactButton, {
			text = props.controls.text,
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
