local React = require("@pkg/React")
local ModuleLoader = require("@pkg/ModuleLoader")
local PluginApp = require("./PluginApp")

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	story = React.createElement(PluginApp, {
		loader = ModuleLoader.new(),
		plugin = plugin,
	}),
}
