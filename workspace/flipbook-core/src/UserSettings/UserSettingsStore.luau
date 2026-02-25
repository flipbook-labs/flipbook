local Charm = require("@pkg/Charm")
local t = require("@pkg/t")

local createPluginSettingsStore = require("@root/Plugin/createPluginSettingsStore")
local defaultSettings = require("@root/UserSettings/defaultSettings")

export type UserSettings = {
	rememberLastOpenedStory: boolean,
	theme: string,
	sidebarWidth: number,
	controlsHeight: number,
	collectAnonymousUsageData: boolean,
}

local defaultValue: UserSettings = {
	rememberLastOpenedStory = defaultSettings.rememberLastOpenedStory.value,
	theme = defaultSettings.theme.choices[1].name,
	sidebarWidth = defaultSettings.sidebarWidth.value,
	controlsHeight = defaultSettings.controlsHeight.value,
	collectAnonymousUsageData = defaultSettings.collectAnonymousUsageData.value,
}

local validate = t.interface({
	rememberLastOpenedStory = t.boolean,
	theme = t.string,
	sidebarWidth = t.number,
	controlsHeight = t.number,
	collectAnonymousUsageData = t.boolean,
})

-- defaultValue needs to be kept in sync with the keys in defaultSettings
for key in defaultSettings do
	assert(defaultValue[key] ~= nil, "setting with key {key} is missing from UserSettingsStore")
end

return {
	get = Charm.computed(function()
		return createPluginSettingsStore("FlipbookUserSettings", defaultValue, validate)
	end),
}
