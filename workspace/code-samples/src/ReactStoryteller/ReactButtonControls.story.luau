local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ReactButton = require("./ReactButton")

local controls = {
	text = "Click Me",
	isDisabled = false,
}

type Controls = {
	text: string,
	isDisabled: boolean,
}

type Props = {
	controls: typeof(controls),
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(props: Props)
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
