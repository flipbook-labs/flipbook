local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local PluginApp = require("./PluginApp")

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new() :: any,
	}, {
		PluginApp = React.createElement(PluginApp, {
			plugin = plugin,
		}),
	}),
}
