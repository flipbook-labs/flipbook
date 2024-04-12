local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local PluginApp = require(script.Parent.PluginApp)
local React = require(flipbook.Packages.React)

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	story = React.createElement(PluginApp, {
		loader = ModuleLoader.new(),
		plugin = plugin,
	}),
}
