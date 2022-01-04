local Packages = script.Parent.Parent.Packages

local ModuleLoader = require(Packages.ModuleLoader)
local Roact = require(Packages.Roact)
local types = require(script.Parent.Parent.types)

local loader = ModuleLoader.new()

local function useStory(hooks: any, module: ModuleScript): types.Story?
	local story, setStory = hooks.useState(nil)

	local loadStory = hooks.useCallback(function()
		if not module then
			return
		end

		loader:clear()

		-- Roact needs to be cached so that the story is using the same
		-- table instance as the plugin
		loader:cache(Packages.Roact, Roact)

		local result = loader:require(module)

		if typeof(result) == "table" and result.story then
			setStory(result)
		else
			print("could not select story", module:GetFullName())
		end
	end, { module })

	hooks.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStory)

		loadStory()

		return function()
			conn:Disconnect()
		end
	end, { module })

	return story
end

return useStory
