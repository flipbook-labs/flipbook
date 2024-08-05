local NoStorySelected = require("./NoStorySelected")
local React = require("@pkg/React")

local stories = {}

stories.Primary = React.createElement(NoStorySelected)

return {
	stories = stories,
}
