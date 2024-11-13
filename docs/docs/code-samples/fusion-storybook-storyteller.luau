local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local storybook: Storyteller.Storybook = {
	storyRoots = {
		script.Parent.Components,
	},
	packages = {
		Fusion = Fusion,
	},
}

return storybook
