local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local actions = require("@root/actions")

local CONFIG: AgentGateway.Config = {
	name = "FlipbookAgentGateway",
	protocolVersion = 1,
}

local function listActions(): { Action }
	local result: { Action } = {}
	for _, action in actions do
		table.insert(result, action)
	end
	table.sort(result, function(left, right)
		return left.name < right.name
	end)
	return result
end

local function createAgentGateway(controller: types.AgentController): () -> ()
	local registry = AgentGateway.createActionRegistry(CONFIG, controller, listActions())
	return AgentGateway.createGateway(registry, CONFIG)
end

return createAgentGateway
