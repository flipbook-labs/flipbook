local Example = script:FindFirstAncestor("Example")

local React = require(Example.Parent.Packages.React)
local ReactCounter = require(script.Parent.ReactCounter)
local ReactRoblox = require(Example.Parent.Packages.ReactRoblox)

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
	story = function(props: Props)
		return React.createElement(ReactCounter, {
			increment = props.controls.increment,
			waitTime = props.controls.waitTime,
		})
	end,
}
