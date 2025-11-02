local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local TelemetryOptOutDialog = require("./TelemetryOptOutDialog")

return {
	story = function(props)
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
			overlayGui = props.container,
		}, {
			TelemetryOptOutDialog = React.createElement(TelemetryOptOutDialog),
		})
	end,
}
