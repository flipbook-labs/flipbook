local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local types = require(script.Parent.Parent.types)
local loadStoryModule = require(script.Parent.Parent.Modules.loadStoryModule)

local function useStory(
	hooks: any,
	module: ModuleScript,
	storybook: types.Storybook,
	loader: ModuleLoader.Class
): types.Story?
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
