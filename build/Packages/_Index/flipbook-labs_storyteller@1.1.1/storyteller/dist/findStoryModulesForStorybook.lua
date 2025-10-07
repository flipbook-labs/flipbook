local Sift = require(script.Parent.Parent.Sift)

local isStoryModule = require(script.Parent.isStoryModule)
local matchDescendants = require(script.Parent.matchDescendants)
local types = require(script.Parent.types)
--[=[
	Discovers all Story modules that are managed by the given Storybook.

	@tag Storybook
	@tag Story
	@tag Discovery
	@within Storyteller
	@since 0.1.0
]=]

local function findStoryModulesForStorybook(storybook: types.LoadedStorybook): { ModuleScript }
	local storyModules = {}
	for _, root in storybook.storyRoots do
		storyModules = Sift.List.join(
			storyModules,
			matchDescendants(root, function(descendant)
				return isStoryModule(descendant)
			end)
		)
	end
	return storyModules
end

return findStoryModulesForStorybook
