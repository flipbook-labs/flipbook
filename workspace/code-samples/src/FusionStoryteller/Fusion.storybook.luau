local Fusion = require("@pkg/Fusion")
local Storyteller = require("@pkg/Storyteller")

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
