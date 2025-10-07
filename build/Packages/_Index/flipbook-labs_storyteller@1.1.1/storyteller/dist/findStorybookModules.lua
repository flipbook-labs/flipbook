local isStorybookModule = require(script.Parent.isStorybookModule)
local matchDescendants = require(script.Parent.matchDescendants)
--[=[
	Discovers all Storybook modules that are descendants of `parent`.

	This is the first step in the discovery of Stories. Once you load a
	Storybook, you can then use its `storyRoots` array to discover all the
	Stories it manages.

	@within Storyteller
	@tag Storybook
	@tag Discovery
]=]

local function findStorybookModules(parent: Instance): { ModuleScript }
	local storybooks = matchDescendants(parent, function(descendant)
		return isStorybookModule(descendant)
	end)

	-- Luau FIXME: isStorybookModule already narrows to ModuleScript, but Luau
	-- doesn't pick up on it
	return (storybooks :: any) :: { ModuleScript }
end

return findStorybookModules
