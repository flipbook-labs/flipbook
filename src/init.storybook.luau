local React = require("@pkg/react")
local ReactRoblox = require("@pkg/react-roblox")

return {
	name = script.Parent.Name,
	storyRoots = {
		script.Parent,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
