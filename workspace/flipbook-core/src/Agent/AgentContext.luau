local React = require("@pkg/React")

local FlipbookAgents = require("@workspace/flipbook-agents/src")

type AgentController = FlipbookAgents.AgentController

local Context = React.createContext(nil :: AgentController?)

local function use(): AgentController?
	return React.useContext(Context)
end

return {
	Provider = Context.Provider,
	use = use,
}
