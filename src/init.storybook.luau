local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	name = script.Parent.Name,
	storyRoots = {
		script.Parent,
	},
	react = React,
	reactRoblox = ReactRoblox,
}
