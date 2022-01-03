local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Counter = require(script.Parent.Counter)

return {
	summary = "A simple counter that increments every second",
	controls = {
		increment = 1,
	},
	story = function(props)
		return Roact.createElement(Counter, {
			increment = props.controls.increment,
		})
	end,
}
