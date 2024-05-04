local React = require("@pkg/React")

local ContextStack = require("@root/Common/ContextStack")
local MockPlugin = require("@root/Testing/MockPlugin")
local PluginContext = require("@root/Plugin/PluginContext")
local SettingsContext = require("./SettingsContext")
local SettingsView = require("./SettingsView")

return {
	story = function()
		return React.createElement(ContextStack, {
			providers = {
				React.createElement(PluginContext.Provider, {
					plugin = MockPlugin.new(),
				}),
				React.createElement(SettingsContext.Provider),
			},
		}, {
			SettingsView = React.createElement(SettingsView),
		})
	end,
}
