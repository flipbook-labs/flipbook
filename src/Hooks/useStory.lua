local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local types = require(script.Parent.Parent.types)
local loadStoryModule = require(flipbook.Story.loadStoryModule)

local function useStory(module: ModuleScript, storybook: types.Storybook, loader: any): (types.Story?, string?)
	local state, setState = React.useState({
		story = nil,
		err = nil,
	})

	local loadStory = React.useCallback(function()
		local story, err = loadStoryModule(loader, module, storybook)

		if story and story.controls and story.fusion then
			local newControls = {}
			for k, v in story.controls do
				newControls[k] = story.fusion.Value(v)
			end
			story.controls = newControls
		end

		setState({
			story = story,
			err = err,
		})
	end, { loader, module, storybook })

	React.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(function()
			-- ModuleLoader will call _clearConsumerFromCache on the module that
			-- was changed, but that doesn't remove the story module from the
			-- cache. This leads to an issue where loading the story again is
			-- returning nil, so we have to manually remove the story module
			-- from the cache to get everything working
			loader:_clearConsumerFromCache(module:GetFullName())

			loadStory()
		end)

		loadStory()

		return function()
			conn:Disconnect()
		end
	end, { module, loadStory, loader })

	return state.story, state.err
end

return useStory
