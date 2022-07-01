local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Button = require(script.Parent.Button)

return {
	summary = "Generic button",
	story = Roact.createElement(Button, {}),
}
