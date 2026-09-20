local Charm = require("@pkg/Charm")
local t = require("@pkg/t")

local createPluginSettingsStore = require("@root/Plugin/createPluginSettingsStore")

export type LocalStorageStore = {
	lastOpenedStoryPath: string?,
	pinnedInstancePaths: { string }?,
}

local defaultValue: LocalStorageStore = {}

local validate = t.interface({
	lastOpenedStoryPath = t.optional(t.string),
	pinnedInstancePaths = t.optional(t.array(t.string)),
})

-- Initialize the store eagerly at module level so createPluginSettingsStore's
-- internal Charm.effect is a top-level effect, not one nested inside a computed.
local get = Charm.signal(createPluginSettingsStore("FlipbookLocalStorage", defaultValue, validate))

return {
	get = get,
}
