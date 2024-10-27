local React = require("@pkg/React")
local ReactCounter = require("./ReactCounter")
local ReactRoblox = require("@pkg/ReactRoblox")

local controls = {
	increment = 1,
	waitTime = 1,
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A simple counter that increments every second. This is a copy of the Counter component, but written with React",
	controls = controls,
	react = React,
	reactRoblox = ReactRoblox,
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
	story = function(props: Props)
		return React.createElement(ReactCounter, {
			increment = props.controls.increment,
			waitTime = props.controls.waitTime,
		})
	end,
}
