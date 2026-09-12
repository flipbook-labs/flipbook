local Charm = require("@pkg/Charm")

local createNavigationStore = require("@self/createNavigationStore")

return {
	get = Charm.computed(createNavigationStore),
}
