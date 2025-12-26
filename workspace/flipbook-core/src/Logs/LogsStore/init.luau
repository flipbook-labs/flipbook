local Signals = require("@rbxpkg/Signals")

local createLogsStore = require("@self/createLogsStore")

return {
	get = Signals.createComputed(createLogsStore),
}
