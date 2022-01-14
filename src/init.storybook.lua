local Roact = require(script.Parent.Packages.Roact)

return {
	name = script.Parent.Name,
	summary = "The one (and only) storybook for flipbook",
	storyRoots = {
		script.Parent.Components,
	},
	roact = Roact,
}
