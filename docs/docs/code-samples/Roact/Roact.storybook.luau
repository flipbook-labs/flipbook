local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

return {
	storyRoots = {
		script.Parent.Components,
	},
	packages = {
		Roact = Roact,
	},
}
