local Checkbox = require("./Checkbox")
local React = require("@pkg/React")

local stories = {}

stories.Primary = React.createElement(Checkbox, {
	initialState = true,
	onStateChange = function(newState)
		print("Checkbox state changed to", newState)
	end,
})

return {
	summary = "Generic checkbox used for story controls",
	stories = stories,
}
