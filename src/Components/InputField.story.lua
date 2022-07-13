local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local InputField = require(script.Parent.InputField)

return {
	story = Roact.createElement(InputField, {
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
