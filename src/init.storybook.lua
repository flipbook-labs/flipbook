local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)

return {
	name = flipbook.Name,
	storyRoots = {
		flipbook.Components,
	},
	renderer = React,
}
