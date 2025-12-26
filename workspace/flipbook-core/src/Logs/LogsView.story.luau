local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local LogsView = require("./LogsView")

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			LogsView = React.createElement(LogsView),
		})
	end,
}
