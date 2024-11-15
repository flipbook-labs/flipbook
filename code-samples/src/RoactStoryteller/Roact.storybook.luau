local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local storybook: Storyteller.Storybook = {
	name = "Roact (Storyteller)",
	storyRoots = {
		script.Parent,
	},
	packages = {
		Roact = Roact,
	},
}

return storybook
