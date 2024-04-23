local flipbook = script:FindFirstAncestor("flipbook")

local InputField = require(script.Parent.InputField)
local React = require("@pkg/React")

local stories = {}

stories.Primary = React.createElement(InputField, {
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
})

return {
	stories = stories,
}
