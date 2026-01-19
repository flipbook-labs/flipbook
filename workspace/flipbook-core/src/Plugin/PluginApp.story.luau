local React = require("@pkg/React")

local PluginApp = require("./PluginApp")

return {
	summary = "The main component that handles the entire plugin",
	controls = {},
	story = function()
		return React.createElement(PluginApp)
	end,
}
