local React = require("@pkg/React")
local constants = require("@root/constants")
local isStorybookModule = require("@root/Storybook/isStorybookModule")
local types = require("@root/Storybook/types")
local useDescendants = require("@root/Common/useDescendants")

local function hasPermission(instance: Instance)
	local success = pcall(function()
		return instance.Name
	end)
	return success
end

local function useStorybooks(parent: Instance, loader: any)
	local storybooks, set = React.useState({})
	local modules = useDescendants(game, function(descendant)
		return hasPermission(descendant) and isStorybookModule(descendant)
	end)

	local loadStorybooks = React.useCallback(function()
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
	end, { set, parent, loader, modules } :: { unknown })

	React.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(function(other)
			if types.Storybook(other) then
				loadStorybooks()
			end
		end)

		loadStorybooks()

		return function()
			conn:Disconnect()
		end
	end, { loadStorybooks, loader })

	return storybooks
end

return useStorybooks
