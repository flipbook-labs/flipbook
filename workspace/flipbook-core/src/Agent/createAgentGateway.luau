local AgentGateway = require("@pkg/AgentGateway")

local Actions = require("@root/Agent/actions")
local AppStore = require("@root/AppStore")
local CommonTypes = require("@root/Common/types")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")

type Pluginlike = CommonTypes.Pluginlike
type Context = Actions.Context

local CONFIG: AgentGateway.Config = {
	name = "FlipbookAgentGateway",
	protocolVersion = 1,
}

local function withTelemetry(registry)
	return {
		actions = registry.actions,
		manifest = registry.manifest,
		dispatch = function(name: string, params: unknown?)
			local result = registry.dispatch(name, params)

			task.spawn(function()
				fireEventAsync({
					eventName = "AgentActionInvoked",
					properties = {
						action = name,
						ok = result.ok,
					},
				})
			end)

			return result
		end,
	}
end

local function createAgentGateway(plugin: Pluginlike, widget: DockWidgetPluginGui): () -> ()
	local context: Context = {
		plugin = plugin :: any,
		store = AppStore.get(),
		widget = widget,
	}

	local registry = AgentGateway.createActionRegistry(CONFIG, context, Actions.create(context))
	local cleanup = AgentGateway.createGateway(withTelemetry(registry), CONFIG)

	return cleanup
end

return createAgentGateway
