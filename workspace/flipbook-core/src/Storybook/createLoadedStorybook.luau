local ModuleLoader = require("@pkg/ModuleLoader")
local Storyteller = require("@pkg/Storyteller")

type LoadedStorybook = Storyteller.LoadedStorybook

local function createLoadedStorybook(): LoadedStorybook
	return {
		name = "Storybook",
		loader = ModuleLoader.new(),
		source = Instance.new("ModuleScript"),
		storyRoots = {},
	}
end

return createLoadedStorybook
