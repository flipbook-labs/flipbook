local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	name = "FlipbookCore",
	storyRoots = {
		script.Parent,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
