local flipbook = script:FindFirstAncestor("flipbook")

local types = require(script.Parent.Parent.types)
local loadStoryModule = require(flipbook.Story.loadStoryModule)

local function useStory(hooks: any, module: ModuleScript, storybook: types.Storybook, loader: any): types.Story?
	local state, setState = hooks.useState({
		story = nil,
		err = nil,
	})

	local loadStory = hooks.useCallback(function()
		local story, err = loadStoryModule(loader, module)

		if story and not story.roact then
			story.roact = storybook.roact
		end

		setState({
			story = story,
			err = err,
		})
	end, { loader, module, storybook })

	hooks.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStory)

		loadStory()

		return function()
			conn:Disconnect()
		end
	end, { module, loadStory, loader })

	return state.story, state.err
end

return useStory
