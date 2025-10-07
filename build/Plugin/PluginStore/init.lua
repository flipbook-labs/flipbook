local Signals = require(script.Parent.Parent.RobloxPackages.Signals)

local createPluginStore = require(script.createPluginStore)

return {
	get = Signals.createComputed(createPluginStore),
}
