local Roact = require(script.Parent.Parent.Packages.Roact)
local SampleStory = require(script.Parent["Sample.story"])
local StoryList = require(script.Parent.StoryList)

return {
	story = Roact.createElement(StoryList, {
		stories = {
			SampleStory,
		},
		onStorySelected = function(story)
			print(story.name)
		end,
	}),
}
