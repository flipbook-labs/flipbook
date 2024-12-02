local Counter = require("./Counter")
local Roact = require("@pkg/roact")

local controls = {
	increment = 1,
	waitTime = 1,
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A simple counter that increments every second",
	controls = controls,
	roact = Roact,
	story = function(props: Props)
		return Roact.createElement(Counter, {
			increment = props.controls.increment,
			waitTime = props.controls.waitTime,
		})
	end,
}
