local constants = require(script.Parent.Parent.constants)
local isStorybookModule = require(script.Parent.Parent.Modules.isStorybookModule)

local function hasPermission(instance: Instance)
	local success = pcall(function()
		return instance.Name
	end)
	return success
end

local function useStorybooks(hooks: any, parent: Instance)
	local storybooks, set = hooks.useState({})

	local getStorybooks = hooks.useCallback(function()
		local newStorybooks = {}

		for _, descendant in ipairs(parent:GetDescendants()) do
			if isStorybookModule(descendant) then
				local success, result = pcall(function()
					return require(descendant)
				end)

				if success and typeof(result) == "table" and result.storyRoots then
					result.name = result.name or descendant.Name:gsub(constants.STORYBOOK_NAME_PATTERN, "")
					table.insert(newStorybooks, result)
				end
			end
		end

		return newStorybooks
	end, { parent })

	local onDataModelChanged = hooks.useCallback(function(instance: Instance)
		if hasPermission(instance) and isStorybookModule(instance) then
			set(getStorybooks())
		end
	end, { set })

	hooks.useEffect(function()
		set(getStorybooks())
	end, { parent })

	hooks.useEffect(function()
		local added = parent.DescendantAdded:Connect(onDataModelChanged)
		local removing = parent.DescendantRemoving:Connect(onDataModelChanged)

		return function()
			added:Disconnect()
			removing:Disconnect()
		end
	end, { set, getStorybooks })

	return storybooks
end

return useStorybooks
