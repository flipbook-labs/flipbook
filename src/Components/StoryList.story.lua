local Roact = require(script.Parent.Parent.Packages.Roact)
local SampleStory = require(script.Parent["Sample.story"])
local StoryList = require(script.Parent.StoryList)

return {
	story = Roact.createElement(StoryList, {
		storybooks = {
			SampleStory,
		},
		onStorybookSelected = function(storybook)
			print(storybook.name)
		end,
	}),
}
