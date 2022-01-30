local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryView = require(script.Parent.StoryView)

local function Story()
	local loader = ModuleLoader.new()
	loader:cache(script.Parent.Parent.Packages.Roact, Roact)

	local storybook = loader:require(script.Parent.Parent["init.storybook"])

	return Roact.createElement(StoryView, {
		story = script.Parent["Button.story"],
		storybook = storybook,
		loader = loader,
	})
end

return {
	story = Story,
}
