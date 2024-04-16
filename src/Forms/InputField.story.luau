local InputField = require("./InputField")
local React = require("@pkg/React")

return {
	story = React.createElement(InputField, {
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
}
