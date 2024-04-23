local Branding = require("./Branding")
local React = require("@pkg/React")

local stories = {}

stories.Primary = React.createElement(Branding)

return {
	summary = "Icon and Typography for flipbook",
	stories = stories,
}
