local Example = script:FindFirstAncestor("Example")

local Counter = require(script.Parent.Counter)
local Roact = require(Example.Parent.Packages.Roact)

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
