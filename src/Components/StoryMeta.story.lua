local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryMeta = require(script.Parent.StoryMeta)

return {
	story = Roact.createElement(StoryMeta, {
		story = {
			name = "Sample.story",
			summary = "A summary of the current story",
		},
		controls = {
			Foo = true,
			Bar = "string",
		},
		storyModule = script.Parent,
		storyParent = workspace,
	}),
}
