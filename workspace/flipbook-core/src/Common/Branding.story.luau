local React = require("@pkg/React")

local Branding = require("./Branding")

return {
	summary = "Icon and Typography for Flipbook",
	controls = {},
	story = function()
		return React.createElement(Branding)
	end,
}
