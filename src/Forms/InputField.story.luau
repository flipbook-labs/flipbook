local flipbook = script:FindFirstAncestor("flipbook")

local InputField = require(script.Parent.InputField)
local React = require(flipbook.Packages.React)

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
