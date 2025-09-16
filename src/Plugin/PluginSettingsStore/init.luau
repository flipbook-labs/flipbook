local Signals = require("@rbxpkg/Signals")

local createPluginSettingsStore = require("@self/createPluginSettingsStore")

return {
	get = Signals.createComputed(function(_scope)
		return createPluginSettingsStore(plugin, "FlipbookStorageKey")
	end),
}
