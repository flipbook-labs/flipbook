local flipbook = script:FindFirstAncestor("flipbook")

local constants = require(flipbook.constants)
local isStorybook = require(flipbook.Story.isStorybook)
local isStorybookModule = require(flipbook.Story.isStorybookModule)
local useDescendants = require(flipbook.Hooks.useDescendants)

local internalStorybook = flipbook["init.storybook"]

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
			-- Skip over flipbook's internal storybook
			if module == internalStorybook and not constants.IS_DEV_MODE then
				continue
			end

			local success, result = pcall(function()
				return loader:require(module)
			end)

			if success and isStorybook(result) then
				result.name = if result.name
					then result.name
					else module.Name:gsub(constants.STORYBOOK_NAME_PATTERN, "")

				table.insert(newStorybooks, result)
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
