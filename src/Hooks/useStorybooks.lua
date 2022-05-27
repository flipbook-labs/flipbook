local constants = require(script.Parent.Parent.constants)
local isStorybookModule = require(script.Parent.Parent.Modules.isStorybookModule)

local internalStorybook = script.Parent.Parent["init.storybook"]

local function hasPermission(instance: Instance)
	local success = pcall(function()
		return instance.Name
	end)
	return success
end

local function useStorybooks(hooks: any, parent: Instance, loader: any)
	local storybooks, set = hooks.useState({})

	local loadStorybooks = hooks.useCallback(function()
		local newStorybooks = {}

		loader:clear()

		for _, descendant in ipairs(parent:GetDescendants()) do
			-- Skip over flipbook's internal storybook
			if descendant == internalStorybook and not constants.DEBUG_SHOW_INTERNAL_STORYBOOK then
				continue
			end

			if isStorybookModule(descendant) then
				local success, result = pcall(function()
					return loader:require(descendant)
				end)

				if success and typeof(result) == "table" and result.storyRoots then
					result.name = result.name or descendant.Name:gsub(constants.STORYBOOK_NAME_PATTERN, "")
					table.insert(newStorybooks, result)
				end
			end
		end

		set(newStorybooks)
	end, { set, parent, loader })

	local onDataModelChanged = hooks.useCallback(function(instance: Instance)
		if hasPermission(instance) and isStorybookModule(instance) then
			loadStorybooks()
		end
	end, { loadStorybooks })

	hooks.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStorybooks)

		loadStorybooks()

		return function()
			conn:Disconnect()
		end
	end, { loadStorybooks })

	hooks.useEffect(function()
		local added = parent.DescendantAdded:Connect(onDataModelChanged)
		local removing = parent.DescendantRemoving:Connect(onDataModelChanged)

		return function()
			added:Disconnect()
			removing:Disconnect()
		end
	end, { set, loadStorybooks })

	return storybooks
end

return useStorybooks
