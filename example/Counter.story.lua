local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Counter = require(script.Parent.Counter)

return {
	summary = "A simple counter that increments every second",
	controls = {
		Increment = 1,
		["Wait time"] = 1,
	},
	roact = Roact,
	story = function(props)
		return Roact.createElement(Counter, {
			increment = props.controls["Increment"],
			waitTime = props.controls["Wait time"],
		})
	end,
}
