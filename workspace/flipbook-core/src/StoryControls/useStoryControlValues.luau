local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")

type StoryControls = Storyteller.StoryControls

local function useStoryControlValues(): StoryControls
	local storyControls = StoryControlsContext.useStoryControls()
	return ReactCharm.useSignalState(storyControls.getControls, { storyControls })
end

return useStoryControlValues
