local HelloWorld = require(script.Parent.HelloWorld)

local controls = {
	nameToGreet = "World",
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	summary = `Welcome to your first story! The storybook module can be found under ReplicatedStorage. You can also right click it in the sidebar and select "Select in Explorer." Try making changes to the HelloWorld and HelloWorld.story modules to see how the visuals update`,
	story = function(props: Props)
		return HelloWorld({
			nameToGreet = props.controls.nameToGreet,
		})
	end,
}
