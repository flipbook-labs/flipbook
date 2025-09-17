local React = require("@pkg/React")

local ReactButtonControls = require("./ReactButtonControls")

local controls = {
	text = "Click Me",
	isDisabled = false,
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	story = function(props: Props)
		return React.createElement(ReactButtonControls, {
			text = props.controls.text,
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}
