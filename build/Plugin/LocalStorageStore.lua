local Signals = require(script.Parent.Parent.RobloxPackages.Signals)
local t = require(script.Parent.Parent.Packages.t)

local createPluginSettingsStore = require(script.Parent.createPluginSettingsStore)

export type LocalStorageStore = {
	lastOpenedStoryPath: string?,
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
