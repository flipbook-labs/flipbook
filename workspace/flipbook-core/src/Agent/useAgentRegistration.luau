local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local AgentContext = require("@root/Agent/AgentContext")
local createAppAdapter = require("@root/Agent/createAppAdapter")
local embedFlipbookRuntime = require("@root/Embedding/embedFlipbookRuntime")

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

type Storybooks = {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}

export type Options = {
	getCurrentStory: () -> (ModuleScript?, LoadedStorybook?),
	storybooks: Storybooks,
	openStory: (storyModule: ModuleScript, storybook: LoadedStorybook?) -> (),
}

local function useAgentRegistration(options: Options)
	local agentController = AgentContext.use()
	local latest = React.useRef(options)
	latest.current = options

	React.useEffect(function()
		if agentController == nil then
			return
		end

		return agentController.registerApp(createAppAdapter({
			embedFlipbook = embedFlipbookRuntime,
			getStorybooks = function()
				return latest.current.storybooks
			end,
			getCurrentStory = function()
				return latest.current.getCurrentStory()
			end,
			openStory = function(storyModule, storybook)
				latest.current.openStory(storyModule, storybook)
			end,
		}))
	end, { agentController })
end

return useAgentRegistration
