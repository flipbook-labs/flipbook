local Signals = require("@rbxpkg/Signals")

export type PluginStore = {
	getPlugin: () -> Plugin?,
	setPlugin: (plugin: Plugin) -> (),
}

local function createPluginStore()
	local getPlugin, setPlugin = Signals.createSignal(nil :: Plugin?)

	return {
		getPlugin = getPlugin,
		setPlugin = setPlugin,
	}
end

return createPluginStore
