local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Storyteller = require(script.Parent.Parent.Packages.Storyteller)

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
