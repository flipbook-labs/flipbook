local Signals = require("@rbxpkg/Signals")
local t = require("@pkg/t")

local constants = require("@root/constants")
local createPluginSettingsStore = require("@root/Plugin/createPluginSettingsStore")

export type UserSettings = {
	rememberLastOpenedStory: boolean,
	theme: "light" | "dark" | "system",
	sidebarWidth: number,
	controlsHeight: number,
}

local defaultValue: UserSettings = {
	rememberLastOpenedStory = true,
	theme = "system",
	sidebarWidth = constants.SIDEBAR_INITIAL_WIDTH,
	controlsHeight = constants.CONTROLS_INITIAL_HEIGHT,
}

local validate = t.interface({
	rememberLastOpenedStory = t.boolean,
	theme = t.union(t.literal("light"), t.literal("dark"), t.literal("system")),
	sidebarWidth = t.number,
	controlsHeight = t.number,
})

return {
	get = Signals.createComputed(function(_scope)
		return createPluginSettingsStore(plugin, "FlipbookUserSettings", defaultValue, validate)
	end),
}
