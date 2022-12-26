local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)

return {
	storyRoots = {
		script.Parent,
	},
	roact = Roact,
}
