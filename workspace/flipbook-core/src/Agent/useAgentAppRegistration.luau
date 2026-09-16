local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local AgentContext = require("@root/Agent/AgentContext")
local createAppImplementation = require("@root/Agent/createAppImplementation")
local embedFlipbookRuntime = require("@root/Embedding/embedFlipbookRuntime")

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

type Storybooks = {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}

export type Options = {
	storyModule: ModuleScript?,
	storybook: LoadedStorybook?,
	storybooks: Storybooks,
	openStory: (ModuleScript, LoadedStorybook?) -> (),
}

local function useAgentAppRegistration(options: Options)
	local agentController = AgentContext.use()
	local latest = React.useRef(options)
	latest.current = options

	React.useEffect(function()
		if agentController == nil then
			return
		end

		return agentController.registerApp(createAppImplementation({
			embedFlipbook = embedFlipbookRuntime,
			getStorybooks = function()
				return latest.current.storybooks
			end,
			getCurrentStory = function()
				return latest.current.storyModule, latest.current.storybook
			end,
			openStory = function(storyModule, storybook)
				latest.current.openStory(storyModule, storybook)
			end,
		}))
	end, { agentController })
end

return useAgentAppRegistration
