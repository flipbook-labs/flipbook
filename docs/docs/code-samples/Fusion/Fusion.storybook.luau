local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

return {
	storyRoots = {
		script.Parent.Components,
	},
	packages = {
		Fusion = Fusion,
	},
}
