local ButtonWithControls = require("./ButtonWithControls")
local Roact = require("@pkg/Roact")

local controls = {
	isDisabled = false,
	text = "Click me",
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A generic button component that can be used anywhere",
	controls = controls,
	roact = Roact,
	story = function(props: Props)
		return Roact.createElement(ButtonWithControls, {
			text = props.controls.text,
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}
