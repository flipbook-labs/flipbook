local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ReactButtonTypedControls = require("./ReactButtonTypedControls")

local controls: Storyteller.StoryControlsSchema = {
	text = Storyteller.createStringControl("Click Me"),
	fontSize = Storyteller.createSliderControl(16, NumberRange.new(8, 32), 1),
	textColor = Storyteller.createColorControl(Color3.fromRGB(50, 50, 50)),
	isDisabled = Storyteller.createBooleanControl(false),
	size = Storyteller.createSelectControl({ "Small", "Medium", "Large" }, {
		default = "Medium",
	}),
}

local story: Storyteller.Story<any> = {
	controls = controls,
	story = function(props)
		return React.createElement(ReactButtonTypedControls, {
			text = props.controls.text,
			fontSize = props.controls.fontSize,
			textColor = props.controls.textColor,
			isDisabled = props.controls.isDisabled,
			size = props.controls.size,
			onActivated = function()
				print("clicked!")
			end,
		})
	end,
}

return story
