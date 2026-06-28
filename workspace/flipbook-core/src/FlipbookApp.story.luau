local React = require("@pkg/React")

local FlipbookApp = require("./FlipbookApp")

return {
	summary = "The main component that handles the entire Flipbook app",
	controls = {},
	story = function()
		return React.createElement(FlipbookApp)
	end,
}
