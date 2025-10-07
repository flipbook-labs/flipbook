local Signals = require(script.Parent.Parent.RobloxPackages.Signals)
local t = require(script.Parent.Parent.Packages.t)

local createPluginSettingsStore = require(script.Parent.Parent.Plugin.createPluginSettingsStore)
local defaultSettings = require(script.Parent.defaultSettings)

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

-- defaultValue needs to be kept in sync with the keys in defaultSettings
for key in defaultSettings do
	assert(defaultValue[key] ~= nil, "setting with key {key} is missing from UserSettingsStore")
end

return {
	get = Signals.createComputed(function(_scope)
		return createPluginSettingsStore("FlipbookUserSettings", defaultValue, validate)
	end),
}
