local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local StoryMeta = require("./StoryMeta")

return {
	story = function()
		local storybooks = Storyteller.useStorybooks(game)
		local story, setStory = React.useState(nil :: Storyteller.LoadedStory<any>?)

		React.useEffect(function()
			local storybook = storybooks.available[1]

			if storybook then
				local storyModule = Storyteller.findStoryModulesForStorybook(storybook)[1]
				if storyModule then
					setStory(Storyteller.loadStoryModule(storyModule, storybook))
				end
			end
		end, { storybooks.available })

		if not story then
			return
		end

		return React.createElement(StoryMeta, {
			story = story,
		})
	end,
}
