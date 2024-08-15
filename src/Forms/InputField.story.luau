local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local InputField = require("./InputField")
local MockPlugin = require("@root/Testing/MockPlugin")

local stories = {}

stories.Primary = React.createElement(ContextProviders, {
	plugin = MockPlugin.new(),
}, {
	InputField = React.createElement(InputField, {
		placeholder = "Enter information...",
		autoFocus = true,
		onSubmit = function(text)
			print(text)
		end,
		validate = function(text: string)
			return #text <= 4
		end,
		transform = function(text: string)
			return text:upper()
		end,
	}),
})

return {
	stories = stories,
}
