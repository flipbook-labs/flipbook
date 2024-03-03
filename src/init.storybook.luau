local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)

return {
	name = flipbook.Name,
	storyRoots = {
		flipbook,
	},
	react = React,
	reactRoblox = ReactRoblox,
}
