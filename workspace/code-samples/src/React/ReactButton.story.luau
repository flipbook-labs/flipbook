local React = require("@pkg/React")

local ReactButton = require("./ReactButton")

return {
	story = function()
		return React.createElement(ReactButton, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
