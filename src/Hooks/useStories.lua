local constants = require(script.Parent.Parent.constants)
local types = require(script.Parent.Parent.types)

local function useStories(hooks: any, storybook: types.Storybook?): { ModuleScript }
	local stories, setStories = hooks.useState({})

	hooks.useEffect(function()
		if not storybook then
			return
		end

		local newStories = {}

		for _, root in ipairs(storybook.storyRoots) do
			for _, descendant in ipairs(root:GetDescendants()) do
				if descendant.Name:match(constants.STORY_NAME_PATTERN) then
					table.insert(newStories, descendant)
				end
			end
		end

		setStories(newStories)
	end, { storybook })

	return stories
end

return useStories
