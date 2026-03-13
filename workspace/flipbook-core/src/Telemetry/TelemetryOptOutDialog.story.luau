local React = require("@pkg/React")

local TelemetryOptOutDialog = require("./TelemetryOptOutDialog")

return {
	story = function(props)
		return React.createElement(TelemetryOptOutDialog)
	end,
}
