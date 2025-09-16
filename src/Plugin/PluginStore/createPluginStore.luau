local Signals = require("@rbxpkg/Signals")

export type PluginStore = {
	getPlugin: Signals.getter<Plugin?>,
	setPlugin: Signals.setter<Plugin>,
}

local function createPluginStore()
	local getPlugin, setPlugin = Signals.createSignal(nil :: Plugin?)

	return {
		getPlugin = getPlugin,
		setPlugin = setPlugin,
	}
end

return createPluginStore
