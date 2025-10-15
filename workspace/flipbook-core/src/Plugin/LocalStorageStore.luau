local Signals = require("@rbxpkg/Signals")
local t = require("@pkg/t")

local createPluginSettingsStore = require("@root/Plugin/createPluginSettingsStore")

export type LocalStorageStore = {
	lastOpenedStoryPath: string?,
	pinnedInstancePaths: { string }?,
	wasUserPromptedForTelemetry: boolean,
}

local defaultValue: LocalStorageStore = {
	wasUserPromptedForTelemetry = false,
}

local validate = t.interface({
	lastOpenedStoryPath = t.optional(t.string),
	pinnedInstancePaths = t.optional(t.array(t.string)),
	wasUserPromptedForTelemetry = t.boolean,
})

return {
	get = Signals.createComputed(function(_scope)
		return createPluginSettingsStore("FlipbookLocalStorage", defaultValue, validate)
	end),
}
