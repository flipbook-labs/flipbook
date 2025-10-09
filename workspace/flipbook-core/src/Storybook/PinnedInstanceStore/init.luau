local Signals = require("@rbxpkg/Signals")

local createPinnedInstanceStore = require("@self/createPinnedInstanceStore")

return {
	get = Signals.createComputed(createPinnedInstanceStore),
}
