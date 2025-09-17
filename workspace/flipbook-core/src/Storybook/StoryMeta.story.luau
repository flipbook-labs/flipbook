local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryMeta = require("./StoryMeta")

local function Story()
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
end

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Story = React.createElement(Story),
		})
	end,
}
