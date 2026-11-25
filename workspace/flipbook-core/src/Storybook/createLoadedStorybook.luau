local Storyteller = require("@pkg/Storyteller")

type LoadedStorybook = Storyteller.LoadedStorybook

local function createLoadedStorybook(): LoadedStorybook
	return {
		name = "Storybook",
		source = Instance.new("ModuleScript"),
		storyRoots = {},
	}
end

return createLoadedStorybook
