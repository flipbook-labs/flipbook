local HelloWorld = require(script.Parent.HelloWorld)

local controls = {
	nameToGreet = "World",
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	story = function(props: Props)
		return HelloWorld({
			nameToGreet = props.controls.nameToGreet,
		})
	end,
}
