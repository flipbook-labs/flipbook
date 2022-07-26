local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local enums = require(flipbook.enums)
local types = require(script.Parent.Parent.types)
local isStory = require(flipbook.Story.isStory)
local isHoarcekatStory = require(flipbook.Story.isHoarcekatStory)

local Errors = {
	MalformedStory = "Story is malformed. Check the source of %q and make sure it has the correct properties",
	Generic = "Failed to load story %q. Error: %s",
}

local function loadStoryModule(loader: any, module: ModuleScript): (types.Story?, string?)
	if not module then
		return nil, "Did not receive a module to load"
	end

	local success, result = pcall(function()
		return loader:require(module)
	end)

	if not success then
		return nil, Errors.Generic:format(module:GetFullName(), tostring(result))
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
		return nil, Errors.MalformedStory:format(module:GetFullName())
	end
end

return loadStoryModule
