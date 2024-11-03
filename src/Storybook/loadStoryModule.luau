local ModuleLoader = require("@pkg/ModuleLoader")
local Sift = require("@pkg/Sift")

local types = require("@root/Storybook/types")

local Errors = {
	MalformedStory = "Story is malformed. Check the source of %q and make sure its properties are correct",
	Generic = "Failed to load story %q. Error: %s",
}

local function loadStoryModule(
	loader: ModuleLoader.ModuleLoader,
	module: ModuleScript,
	storybook: types.Storybook
): (types.Story?, string?)
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
	else
		local isValid, message = types.StoryMeta(result)

		if isValid then
			local extraProps = {}
			if types.ReactStorybook(storybook) then
				local reactStorybook = storybook :: types.ReactStorybook
				extraProps = {
					react = reactStorybook.react,
					reactRoblox = reactStorybook.reactRoblox,
				}
			elseif types.RoactStorybook(storybook) then
				local roactStorybook = storybook :: types.RoactStorybook
				extraProps = {
					roact = roactStorybook.roact,
				}
			end

			story = Sift.Dictionary.merge({
				name = module.Name,
			}, extraProps, result)
		else
			return nil, Errors.Generic:format(module:GetFullName(), message)
		end
	end

	if story then
		return story, nil
	else
		return nil, Errors.MalformedStory:format(module:GetFullName())
	end
end

return loadStoryModule
