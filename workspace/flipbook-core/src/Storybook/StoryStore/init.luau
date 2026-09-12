local Charm = require("@pkg/Charm")

local createStoryStore = require("@self/createStoryStore")

return {
	get = Charm.computed(createStoryStore),
}
