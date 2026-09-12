local HelloWorld = require(script.Parent.HelloWorld)
local Roact = require(script.Parent.Parent.Roact)

return {
	summary = "This is a Hoarcekat component that has been converted for Flipbook!",
	controls = {
		name = "Flipbook",
	},
	story = function(props)
		return Roact.createElement(HelloWorld, {
			name = props.controls.name,
		})
	end,
}
