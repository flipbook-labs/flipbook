local flipbook = script:FindFirstAncestor("flipbook")

local Sift = require(flipbook.Packages.Sift)
local enums = require(flipbook.enums)
local types = require(script.Parent.Parent.types)

local Errors = {
	MalformedStory = "Story is malformed. Check the source of %q and make sure its properties are correct",
	Generic = "Failed to load story %q. Error: %s",
}

local function loadStoryModule(loader: any, module: ModuleScript, storybook: types.Storybook): (types.Story?, string?)
	if not module then
		return nil, "Did not receive a module to load"
	end

	local success, result = pcall(function()
		return loader:require(module)
	end)

	if not success then
		return nil, Errors.Generic:format(module:GetFullName(), tostring(result))
	end

	local story: types.Story
	if typeof(result) == "function" then
		story = {
			name = module.Name,
			story = result,
		}
	elseif typeof(result) == "table" then
		if not result.roact then
			result.roact = storybook.roact
		end

		story = Sift.Dictionary.merge({
			name = module.Name,
		}, result)
	end

	if story then
		return story, nil
	else
		return nil, Errors.MalformedStory:format(module:GetFullName())
	end
end

return loadStoryModule
