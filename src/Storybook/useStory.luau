local React = require("@pkg/React")
local loadStoryModule = require("@root/Storybook/loadStoryModule")
local types = require("@root/Storybook/types")

local function useStory(module: ModuleScript, storybook: types.Storybook, loader: any): (types.Story?, string?)
	local state, setState = React.useState({} :: {
		story: types.Story?,
		err: string?,
	})

	local loadStory = React.useCallback(function()
		local story, err = loadStoryModule(loader, module, storybook)

		setState({
			story = story,
			err = err,
		})
	end, { loader, module, storybook })

	React.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(function(other)
			if other == module then
				loadStory()
			end
		end)

		loadStory()

		return function()
			conn:Disconnect()
		end
	end, { module, loadStory, loader } :: { unknown })

	return state.story, state.err
end

return useStory
