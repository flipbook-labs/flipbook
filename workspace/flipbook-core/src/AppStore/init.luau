local Charm = require("@pkg/Charm")

local createAppStore = require("@self/createAppStore")

return {
	get = Charm.computed(createAppStore),
}
