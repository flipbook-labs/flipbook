local React = require("@pkg/react")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local SettingsView = require("./SettingsView")

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			SettingsView = React.createElement(SettingsView),
		})
	end,
}
