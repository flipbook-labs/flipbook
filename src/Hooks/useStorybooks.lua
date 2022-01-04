local constants = require(script.Parent.Parent.constants)

local function useStorybooks(hooks: any, parent: Instance)
	local storybooks, set = hooks.useState({})

	hooks.useEffect(function()
		local newStorybooks = {}

		for _, descendant in ipairs(parent:GetDescendants()) do
			if descendant.Name:match(constants.STORYBOOK_NAME_PATTERN) then
				local success, result = pcall(function()
					return require(descendant)
				end)

				if success and typeof(result) == "table" and result.storyRoots then
					result.name = result.name or descendant.Name:gsub(constants.STORYBOOK_NAME_PATTERN, "")
					table.insert(newStorybooks, result)
				end
			end
		end

		set(newStorybooks)
	end, { parent })

	return storybooks
end

return useStorybooks
