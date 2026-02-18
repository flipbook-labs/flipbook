local React = require("@pkg/React")

local NoStorySelected = require("./NoStorySelected")

return {
	story = function()
		return React.createElement(NoStorySelected)
	end,
}
