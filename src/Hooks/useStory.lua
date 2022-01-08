local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local types = require(script.Parent.Parent.types)

local loader = ModuleLoader.new()

local function useStory(hooks: any, module: ModuleScript): types.Story?
	local story, setStory = hooks.useState(nil)
	local err, setErr = hooks.useState(nil)

	local loadStory = hooks.useCallback(function()
		if not module then
			return
		end

		loader:clear()

		local success, result = pcall(function()
			return loader:require(module)
		end)

		setErr(if success then nil else result)

		if typeof(result) == "table" and result.story then
			if not result.name then
				result.name = module.Name
			end

			setStory(result)
		else
			print("could not select story", module:GetFullName())
		end
	end, { module, setStory, setErr })

	hooks.useEffect(function()
		local conn = loader.loadedModuleChanged:Connect(loadStory)

		loadStory()

		return function()
			conn:Disconnect()
		end
	end, { module })

	return story, err
end

return useStory
