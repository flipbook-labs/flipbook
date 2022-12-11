local Roact = require(script.Parent.Packages.Roact)

return {
	name = script.Parent.Name,
	storyRoots = {
		script.Parent.Components,
	},
	roact = Roact,
}
