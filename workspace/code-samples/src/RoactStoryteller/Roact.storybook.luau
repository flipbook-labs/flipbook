local Roact = require("@pkg/Roact")
local Storyteller = require("@pkg/Storyteller")

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
