local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Dropdown = require(flipbook.Components.Fields.Dropdown)

return {
	story = function()
		return Roact.createElement(Dropdown, {
			default = "Option 1",
			options = {
				"Option 1",
				"Option 2",
				"Option 3",
			},
			onOptionChange = function(option)
				print("Selected", option)
			end,
		})
	end,
}
