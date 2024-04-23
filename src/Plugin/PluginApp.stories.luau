local ModuleLoader = require("@pkg/ModuleLoader")
local PluginApp = require("./PluginApp")
local React = require("@pkg/React")

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
