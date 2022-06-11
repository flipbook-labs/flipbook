local flipbook = script:FindFirstAncestor("flipbook")

local types = require(script.Parent.Parent.types)
local loadStoryModule = require(flipbook.Story.loadStoryModule)

local function useStory(hooks: any, module: ModuleScript, storybook: types.Storybook, loader: any): types.Story?
	local state, setState = hooks.useState({
		story = nil,
		err = nil,
	})

	local loadStory = hooks.useCallback(function()
		loader:clear()

		if storybook.roact then
			for cachedModule: ModuleScript in pairs(loader._cache) do
				print(cachedModule.Name)
				if cachedModule.Name:match("Roact") then
					loader:cache(cachedModule, storybook.roact)
				end
			end
		end

		local story, err = loadStoryModule(loader, module)

		print(story.roact ~= nil)
		print(story.roact == storybook.roact)

		print(story)

		story.roact = if story.roact then story.roact else storybook.roact

		setState({
			story = story,
			err = err,
		})
	end, { module })

	hooks.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStory)

		loadStory()

		return function()
			conn:Disconnect()
		end
	end, { module })

	return state.story, state.err
end

return useStory
