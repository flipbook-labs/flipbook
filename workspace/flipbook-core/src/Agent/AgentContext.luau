local React = require("@pkg/React")

local types = require("@root/Agent/types")

local Context = React.createContext(nil :: types.AgentController?)

local function use(): types.AgentController?
	return React.useContext(Context)
end

return {
	Provider = Context.Provider,
	use = use,
}
