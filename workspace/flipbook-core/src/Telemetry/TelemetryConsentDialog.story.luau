local React = require("@pkg/React")

local TelemetryConsentDialog = require("./TelemetryConsentDialog")

return {
	story = function()
		return React.createElement(TelemetryConsentDialog)
	end,
}
