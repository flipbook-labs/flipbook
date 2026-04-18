local Charm = require("@pkg/Charm")

local createPinnedInstanceStore = require("@self/createPinnedInstanceStore")

return {
	get = Charm.computed(createPinnedInstanceStore),
}
