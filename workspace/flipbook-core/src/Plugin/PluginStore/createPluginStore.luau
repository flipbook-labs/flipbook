local Charm = require("@pkg/Charm")

export type PluginStore = {
	getPlugin: () -> Plugin?,
	setPlugin: (((Plugin?) -> Plugin?) | Plugin?) -> Plugin?,
}

--[[
	This is a basic store to keep track of the Plugin instance.

	A quirk of the `plugin` keyword is that it's only defined in top-level
	scripts, like `init.server.luau`. It must be passed along by reference after
	that point, as attempting to use `plugin` in a ModuleScript will result in
	nil value. To work around this, we just toss the plugin instance into this
	store to share it around other parts of the app
]]
local function createPluginStore(): PluginStore
	local getPlugin, setPlugin = Charm.signal(nil :: Plugin?)

	return {
		getPlugin = getPlugin,
		setPlugin = setPlugin,
	}
end

return createPluginStore
