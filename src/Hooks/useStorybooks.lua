local flipbook = script:FindFirstAncestor("flipbook")

local constants = require(flipbook.constants)
local types = require(script.Parent.Parent.types)
local isStorybookModule = require(flipbook.Story.isStorybookModule)
local useDescendants = require(flipbook.Hooks.useDescendants)

local function hasPermission(instance: Instance)
	local success = pcall(function()
		return instance.Name
	end)
	return success
end

local function useStorybooks(hooks: any, parent: Instance, loader: any)
	local storybooks, set = hooks.useState({})
	local modules = useDescendants(hooks, game, function(descendant)
		return hasPermission(descendant) and isStorybookModule(descendant)
	end)

	local loadStorybooks = hooks.useCallback(function()
		local newStorybooks = {}

		for _, module in modules do
			local wasRequired, result = pcall(function()
				return loader:require(module)
			end)

			if wasRequired then
				local success, message = types.Storybook(result)

				if success then
					result.name = if result.name
						then result.name
						else module.Name:gsub(constants.STORYBOOK_NAME_PATTERN, "")

					table.insert(newStorybooks, result)
				else
					warn(("Failed to load storybook %s. Error: %s"):format(module:GetFullName(), message))
				end
			end
		end

		set(newStorybooks)
	end, { set, parent, loader, modules })

	hooks.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStorybooks)

		loadStorybooks()

		return function()
			conn:Disconnect()
		end
	end, { loadStorybooks, loader })

	return storybooks
end

return useStorybooks
