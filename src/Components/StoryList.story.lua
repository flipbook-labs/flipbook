local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryList = require(script.Parent.StoryList)

local SampleStory = script.Parent["Sample.story"]

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
