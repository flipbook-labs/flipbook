local flipbook = script:FindFirstAncestor("flipbook")

local App = require(flipbook.Components.App)
local Roact = require(flipbook.Packages.Roact)

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	story = Roact.createElement(App),
}
