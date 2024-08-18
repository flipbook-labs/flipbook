local React = require("@pkg/React")

local Checkbox = require("./Checkbox")
local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local stories = {}

stories.Primary = React.createElement(ContextProviders, {
	plugin = MockPlugin.new(),
}, {
	Checkbox = React.createElement(Checkbox, {
		initialState = true,
		onStateChange = function(newState)
			print("Checkbox state changed to", newState)
		end,
	}),
})

return {
	summary = "Generic checkbox used for story controls",
	stories = stories,
}
