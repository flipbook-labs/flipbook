local Charm = require("@pkg/Charm")
local Sift = require("@pkg/Sift")
local t = require("@pkg/t")

local createPluginSettingsStore = require("@root/Plugin/createPluginSettingsStore")
local defaultSettings = require("@root/UserSettings/defaultSettings")

export type UserSettings = {
	rememberLastOpenedStory: boolean,
	colorMode: string,
	themeName: string,
	sidebarWidth: number,
	controlsHeight: number,
	collectAnonymousUsageData: boolean,
}

local defaultValue: UserSettings = {
	rememberLastOpenedStory = defaultSettings.rememberLastOpenedStory.value,
	colorMode = defaultSettings.colorMode.choices[1].name,
	themeName = defaultSettings.themeName.choices[1].name,
	sidebarWidth = defaultSettings.sidebarWidth.value,
	controlsHeight = defaultSettings.controlsHeight.value,
	collectAnonymousUsageData = defaultSettings.collectAnonymousUsageData.value,
}

local validate = t.interface({
	rememberLastOpenedStory = t.boolean,
	colorMode = t.string,
	themeName = t.string,
	sidebarWidth = t.number,
	controlsHeight = t.number,
	collectAnonymousUsageData = t.boolean,
})

-- Settings saved by older versions of Flipbook store the color mode as `theme`.
local function migrate(saved: { [string]: any }): { [string]: any }
	if saved.theme ~= nil then
		return Sift.Dictionary.join(saved, {
			colorMode = if saved.colorMode ~= nil then saved.colorMode else saved.theme,
			theme = Sift.None,
		})
	end
	return saved
end

-- defaultValue needs to be kept in sync with the keys in defaultSettings
for key in defaultSettings do
	assert(defaultValue[key] ~= nil, "setting with key {key} is missing from UserSettingsStore")
end

-- Initialize the store eagerly at module level so createPluginSettingsStore's
-- internal Charm.effect is a top-level effect, not one nested inside a computed.
local get = Charm.signal(createPluginSettingsStore("FlipbookUserSettings", defaultValue, validate, migrate))

return {
	get = get,
	migrate = migrate,
}
