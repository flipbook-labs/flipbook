local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Checkbox = require(script.Parent.Checkbox)

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
