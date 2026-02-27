local Charm = require("@pkg/Charm")

local createPluginStore = require("@self/createPluginStore")

return {
	get = Charm.computed(createPluginStore),
}
