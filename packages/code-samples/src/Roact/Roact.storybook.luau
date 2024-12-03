local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

return {
	name = "Roact",
	storyRoots = {
		script.Parent,
	},
	packages = {
		Roact = Roact,
	},
}
