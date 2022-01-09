local Roact = require(script.Parent.Parent.Packages.Roact)
local App = require(script.Parent.App)

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	roact = Roact,
	story = Roact.createElement(App),
}
