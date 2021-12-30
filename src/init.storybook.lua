local Roact = require(script.Parent.Packages.Roact)

return {
	summary = "The one (and only) storybook for RoactStorybook",
	storyRoots = {
		script.Parent.Components,
	},
	roact = Roact,
}
