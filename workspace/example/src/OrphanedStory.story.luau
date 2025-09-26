local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	story = function()
		return React.createElement("TextLabel", {
			Text = "Story!",
		})
	end,
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
