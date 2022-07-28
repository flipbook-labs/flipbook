local flipbook = script:FindFirstAncestor("flipbook")

local constants = require(flipbook.constants)
local isStorybookModule = require(flipbook.Story.isStorybookModule)

local internalStorybook = flipbook["init.storybook"]

local function hasPermission(instance: Instance)
	local success = pcall(function()
		return instance.Name
	end)
	return success
end

local function useStorybooks(hooks: any, parent: Instance, loader: any)
	local storybooks, set = hooks.useState({})
	local nameChangeListeners: { value: { RBXScriptConnection } } = hooks.useValue({})

	local loadStorybooks = hooks.useCallback(function()
		local newStorybooks = {}

		for _, descendant in ipairs(parent:GetDescendants()) do
			-- Skip over flipbook's internal storybook
			if descendant == internalStorybook and not constants.IS_DEV_MODE then
				continue
			end

			if isStorybookModule(descendant) then
				local success, result = pcall(function()
					return loader:require(descendant)
				end)

				if success and typeof(result) == "table" and result.storyRoots then
					result.name = if result.name
						then result.name
						else descendant.Name:gsub(constants.STORYBOOK_NAME_PATTERN, "")

					table.insert(newStorybooks, result)
				end
			end
		end

		set(newStorybooks)
	end, { set, parent, loader })

	local listenForNameChange = hooks.useCallback(function(module: ModuleScript)
		local conn = module:GetPropertyChangedSignal("Name"):Connect(function()
			if module.Name:match(constants.STORYBOOK_NAME_PATTERN) then
				loadStorybooks()
			end
		end)

		table.insert(nameChangeListeners.value, conn)
	end, { loadStorybooks })

	local onDataModelChanged = hooks.useCallback(function(instance: Instance)
		if hasPermission(instance) then
			if isStorybookModule(instance) then
				loadStorybooks()
			elseif instance:IsA("ModuleScript") then
				listenForNameChange(instance)
			end
		end
	end, { loadStorybooks })

	hooks.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStorybooks)

		loadStorybooks()

		return function()
			conn:Disconnect()
		end
	end, { loadStorybooks, loader })

	hooks.useEffect(function()
		local added = parent.DescendantAdded:Connect(onDataModelChanged)
		local removing = parent.DescendantRemoving:Connect(onDataModelChanged)

		return function()
			added:Disconnect()
			removing:Disconnect()

			print(nameChangeListeners.value)
			for _, conn in ipairs(nameChangeListeners.value) do
				conn:Disconnect()
			end
		end
	end, { set, loadStorybooks, onDataModelChanged })

	return storybooks
end

return useStorybooks
