local Roact = require("@pkg/Roact")

return {
	name = "Roact",
	storyRoots = {
		script.Parent,
	},
	packages = {
		Roact = Roact,
	},
}
