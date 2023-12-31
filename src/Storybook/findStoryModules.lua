local flipbook = script:FindFirstAncestor("flipbook")

local isStoryModule = require(flipbook.Storybook.isStoryModule)

local function hasPermission(instance: Instance)
	local success = pcall(function()
		return instance.Name
	end)
	return success
end

local function findStorybookModules(parent: Instance): { ModuleScript }
	local modules = {}
	for _, descendant in parent:GetDescendants() do
		if hasPermission(descendant) and isStoryModule(descendant) then
			table.insert(modules, descendant)
		end
	end
	return modules
end

return findStorybookModules
