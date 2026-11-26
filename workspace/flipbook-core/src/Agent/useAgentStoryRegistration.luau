local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local AgentContext = require("@root/Agent/AgentContext")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local getInstancePath = require("@root/Common/getInstancePath")
local parseControlValues = require("@root/Agent/parseControlValues")

local useEffect = React.useEffect

type StoryControlsSchema = Storyteller.StoryControlsSchema
type StoryControlsStore = createStoryControlsStore.StoryControlsStore
type StoryControlValue = Storyteller.StoryControlValue | { Storyteller.StoryControlValue }

export type LoadedStory = {
	controls: StoryControlsSchema?,
}

--[[
	Lets agents read and change the controls of the story on screen. Once
	`story` has loaded, this registers the story with the agent controller from
	AgentContext, and agents' reads and writes go through `controlsStore`, the
	same store the story's preview renders from. The registration ends when the
	story changes or the component unmounts.
]]
local function useAgentStoryRegistration(
	storyModule: ModuleScript,
	story: LoadedStory?,
	controlsStore: StoryControlsStore
)
	local agentController = AgentContext.use()

	useEffect(
		function()
			if agentController == nil or story == nil then
				return
			end
			return agentController.registerStory({
				path = getInstancePath(storyModule),
				getControls = controlsStore.getControls,
				setControls = function(controls)
					for key, value in parseControlValues(story.controls or {}, controls) do
						controlsStore.setControl(key, value :: StoryControlValue)
					end
					return controlsStore.getControls()
				end,
			})
		end,
		{
			agentController,
			controlsStore,
			story,
			storyModule,
		} :: { unknown }
	)
end

return useAgentStoryRegistration
