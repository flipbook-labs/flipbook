local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local App = require(script.Parent.App)

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	story = Roact.createElement(App),
}
