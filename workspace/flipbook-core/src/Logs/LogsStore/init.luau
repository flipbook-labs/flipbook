local Charm = require("@pkg/Charm")

local createLogsStore = require("@self/createLogsStore")

return {
	get = Charm.computed(createLogsStore),
}
