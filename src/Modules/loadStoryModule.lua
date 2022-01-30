local Llama = require(script.Parent.Parent.Packages.Llama)
local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local enums = require(script.Parent.Parent.enums)
local types = require(script.Parent.Parent.types)
local isStory = require(script.Parent.Parent.Modules.isStory)
local isHoarcekatStory = require(script.Parent.Parent.Modules.isHoarcekatStory)

local function loadStoryModule(loader: ModuleLoader.Class, module: ModuleScript): (types.Story?, string?)
	if not module then
		return nil, "Did not receive a module to load"
	end

	local success, result = pcall(function()
		return loader:require(module)
	end)

	if not success then
		return nil, result
	end

	if isStory(result) then
		local story: types.Story = Llama.Dictionary.join({
			name = module.Name,
			format = enums.Format.Default,
		}, result)

		return story, nil
	elseif isHoarcekatStory(result) then
		local story: types.Story = {
			name = module.Name,
			story = result,
			format = enums.Format.Hoarcekat,
		}

		return story, nil
	else
		return nil, ("Could not select story %s"):format(module:GetFullName())
	end
end

return loadStoryModule
