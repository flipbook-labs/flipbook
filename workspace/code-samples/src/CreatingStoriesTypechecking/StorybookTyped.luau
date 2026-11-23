local Storyteller = require("@pkg/Storyteller")

local storybook: Storyteller.Storybook = {
	storyRoots = {
		script.Parent.Components,
	},
}

return storybook
