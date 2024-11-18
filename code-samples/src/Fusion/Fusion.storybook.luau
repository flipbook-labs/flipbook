local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

return {
	name = "Fusion",
	storyRoots = {
		script.Parent,
	},
	packages = {
		Fusion = Fusion,
	},
}
