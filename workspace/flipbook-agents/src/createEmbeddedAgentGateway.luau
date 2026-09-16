local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local actions: { [string]: Action } = require("@root/actions")

local EMBEDDED_ACTIONS: { Action } = {
	actions.listStorybooks,
	actions.listStories,
	actions.openStory,
	actions.getCurrentStory,
	actions.getControls,
	actions.setControls,
}

local function createEmbeddedAgentGateway(controller: types.AgentController, parent: Instance): () -> ()
	local config: AgentGateway.Config = {
		name = "FlipbookAgentGateway",
		protocolVersion = 1,
		parent = parent,
	}
	local registry = AgentGateway.createActionRegistry(config, controller, EMBEDDED_ACTIONS)
	return AgentGateway.createGateway(registry, config)
end

return createEmbeddedAgentGateway
