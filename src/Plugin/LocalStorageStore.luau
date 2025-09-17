local Signals = require("@rbxpkg/Signals")
local t = require("@pkg/t")

local createPluginSettingsStore = require("@root/Plugin/createPluginSettingsStore")

export type LocalStorageStore = {
	lastOpenedStoryPath: string?,
	pinnedInstancePaths: { string }?,
}

local defaultValue: LocalStorageStore = {}

local validate = t.interface({
	lastOpenedStoryPath = t.optional(t.string),
})

return {
	get = Signals.createComputed(function(_scope)
		return createPluginSettingsStore("FlipbookLocalStorage", defaultValue, validate)
	end),
}
