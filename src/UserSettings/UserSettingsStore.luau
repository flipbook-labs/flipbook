local Signals = require("@rbxpkg/Signals")
local t = require("@pkg/t")

local createPluginSettingsStore = require("@root/Plugin/createPluginSettingsStore")
local defaultSettings = require("@root/UserSettings/defaultSettings")

export type UserSettings = {
	rememberLastOpenedStory: boolean,
	theme: string,
	sidebarWidth: number,
	controlsHeight: number,
}

local defaultValue: UserSettings = {
	rememberLastOpenedStory = defaultSettings.rememberLastOpenedStory.value,
	theme = defaultSettings.theme.choices[1].name,
	sidebarWidth = defaultSettings.sidebarWidth.value,
	controlsHeight = defaultSettings.controlsHeight.value,
}

local validate = t.interface({
	rememberLastOpenedStory = t.boolean,
	theme = t.string,
	sidebarWidth = t.number,
	controlsHeight = t.number,
})

return {
	get = Signals.createComputed(function(_scope)
		return createPluginSettingsStore("FlipbookUserSettings", defaultValue, validate)
	end),
}
