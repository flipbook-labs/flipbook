local flipbook = script:FindFirstAncestor("flipbook")

local types = require(flipbook.types)
local loadStoryModule = require(flipbook.Modules.loadStoryModule)

local function useStory(hooks: any, module: ModuleScript, storybook: types.Storybook, loader: any): types.Story?
	local state, setState = hooks.useState({
		story = nil,
		err = nil,
	})

	local loadStory = hooks.useCallback(function()
		local story, err = loadStoryModule(loader, module)

		story.roact = story.roact or storybook.roact

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
