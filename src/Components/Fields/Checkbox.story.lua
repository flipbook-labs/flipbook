local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Checkbox = require(script.Parent.Checkbox)

return {
	summary = "Generic checkbox used for story controls",
	story = Roact.createElement(Checkbox, {
		initialState = true,
		onStateChange = function(newState)
			print("Checkbox state changed to", newState)
		end,
	}),
}
