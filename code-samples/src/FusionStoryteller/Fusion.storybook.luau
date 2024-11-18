local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local storybook: Storyteller.Storybook = {
	name = "Fusion (Storyteller)",
	storyRoots = {
		script.Parent,
	},
	packages = {
		Fusion = Fusion,
	},
}

return storybook
