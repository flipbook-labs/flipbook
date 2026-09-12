local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")

type StoryControlValue = Storyteller.StoryControlValue | { Storyteller.StoryControlValue }

local function useStoryControlValue(controlName: string): StoryControlValue?
	local storyControls = StoryControlsContext.useStoryControls()
	return ReactCharm.useSignalState(
		storyControls.getControlValue(controlName),
		{ storyControls, controlName } :: { unknown }
	)
end

return useStoryControlValue
