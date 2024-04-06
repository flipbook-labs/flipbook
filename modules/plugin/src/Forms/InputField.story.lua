local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local InputField = require(script.Parent.InputField)

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
