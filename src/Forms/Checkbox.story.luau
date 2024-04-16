local Checkbox = require("./Checkbox")
local React = require("@pkg/React")

return {
	summary = "Generic checkbox used for story controls",
	story = React.createElement(Checkbox, {
		initialState = true,
		onStateChange = function(newState)
			print("Checkbox state changed to", newState)
		end,
	}),
}
