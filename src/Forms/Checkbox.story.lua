local React = require("@pkg/React")
local Checkbox = require("./Checkbox")

return {
	summary = "Generic checkbox used for story controls",
	story = React.createElement(Checkbox, {
		initialState = true,
		onStateChange = function(newState)
			print("Checkbox state changed to", newState)
		end,
	}),
}
