local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local storybook: Storyteller.Storybook = {
	storyRoots = {
		script.Parent.Components,
	},
	packages = {
		Roact = Roact,
	},
}

return storybook
