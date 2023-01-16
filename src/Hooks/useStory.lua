local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local types = require(script.Parent.Parent.types)
local loadStoryModule = require(flipbook.Story.loadStoryModule)

local function useStory(module: ModuleScript, storybook: types.Storybook, loader: any): types.Story?
	local state, setState = React.useState({
		story = nil,
		err = nil,
	})

	local loadStory = React.useCallback(function()
		local story, err = loadStoryModule(loader, module, storybook)

		setState({
			story = story,
			err = err,
		})
	end, { loader, module, storybook })

	React.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStory)

		loadStory()

		return function()
			conn:Disconnect()
		end
	end, { module, loadStory, loader })

	return state.story, state.err
end

return useStory
