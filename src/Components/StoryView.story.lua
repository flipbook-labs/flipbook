local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryView = require(script.Parent.StoryView)

return {
	roact = Roact,
	story = Roact.createElement(StoryView, {
		story = script.Parent["Button.story"],
		loader = ModuleLoader.new(),
	}),
}
