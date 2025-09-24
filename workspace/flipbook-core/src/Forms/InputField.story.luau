local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local InputField = require("./InputField")
local MockPlugin = require("@root/Testing/MockPlugin")

return {
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new() :: any,
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
	}),
}
