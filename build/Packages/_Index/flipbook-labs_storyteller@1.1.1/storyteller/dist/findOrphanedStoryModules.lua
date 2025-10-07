local Sift = require(script.Parent.Parent.Sift)

local isStoryModule = require(script.Parent.isStoryModule)
local matchDescendants = require(script.Parent.matchDescendants)
local types = require(script.Parent.types)
--[=[
	Discovers all Story modules that do not have a Storybook.

	These are all of the Story modules that are not descendants of an instance
	in the `storyRoots` array of the given storybooks.

	@tag Storybook
	@tag Story
	@tag Discovery
	@within Storyteller
]=]

local function findOrphanedStoryModules(parent: Instance, storybooks: { types.LoadedStorybook }): { ModuleScript }
	local storyModules = matchDescendants(parent, isStoryModule)

	local storyRoots = Sift.Array.reduce(storybooks, function(accumulated: { Instance }, storybook)
		return Sift.Array.join(accumulated, storybook.storyRoots)
	end, {})

	local orphans: { ModuleScript } = {}

	for _, storyModule in storyModules do
		local isOrphaned = true

		for _, storyRoot in storyRoots do
			if storyRoot:IsAncestorOf(storyModule) then
				isOrphaned = false
				break
			end
		end

		if isOrphaned then
			table.insert(orphans, storyModule :: ModuleScript)
		end
	end

	return orphans
end

return findOrphanedStoryModules
