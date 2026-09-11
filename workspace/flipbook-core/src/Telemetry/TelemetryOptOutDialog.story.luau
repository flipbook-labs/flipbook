local React = require("@pkg/React")

local TelemetryOptOutDialog = require("./TelemetryOptOutDialog")

return {
	story = function()
		return React.createElement(TelemetryOptOutDialog)
	end,
}
