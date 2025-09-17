local Signals = require("@rbxpkg/Signals")

local createPluginStore = require("@self/createPluginStore")

return {
	get = Signals.createComputed(createPluginStore),
}
