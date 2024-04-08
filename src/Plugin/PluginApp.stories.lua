local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local PluginApp = require(script.Parent.PluginApp)

local stories = {}

stories.Primary = React.createElement(PluginApp, {
	loader = ModuleLoader.new(),
	plugin = plugin,
})

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	stories = stories,
}
