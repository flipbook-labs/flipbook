local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local enums = require(script.Parent.Parent.enums)
local types = require(script.Parent.Parent.types)
local isStory = require(script.Parent.Parent.Formats.isStory)
local isHoarcekatStory = require(script.Parent.Parent.Formats.isHoarcekatStory)

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

		if isStory(result) then
			if not result.name then
				result.name = module.Name
			end

			result.format = enums.Format.Default
			setStory(result)
		elseif isHoarcekatStory(result) then
			local newStory = {
				name = module.Name,
				story = story,
				format = enums.Format.Hoarcekat,
			}

			setStory(newStory)
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
