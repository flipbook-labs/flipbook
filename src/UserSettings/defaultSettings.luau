local constants = require("@root/constants")

export type SettingType = "checkbox" | "dropdown" | "number"

local SettingType = {
	Checkbox = "checkbox" :: "checkbox",
	Dropdown = "dropdown" :: "dropdown",
	Number = "number" :: "number",
}

export type SettingChoice = {
	name: string,
	description: string,
}

type BaseSetting = {
	name: string,
	displayName: string,
	description: string,
	settingType: SettingType,
}

type CheckboxSetting = BaseSetting & {
	settingType: "checkbox",
	value: boolean,
}

type DropdownSetting = BaseSetting & {
	settingType: "dropdown",
	choices: { SettingChoice },
}

type NumberSetting = BaseSetting & {
	settingType: "number",
	range: NumberRange?,
	value: number,
}

export type Setting = CheckboxSetting | DropdownSetting | NumberSetting

-- local expandNodesOnStart: Setting = {
-- 	name = "expandNodesOnStart",
-- 	displayName = "Expand nodes on start",
-- 	description = "Re-open the storybooks and folders from before",
-- 	settingType = SettingType.Dropdown,
-- 	choices = {
-- 		{
-- 			name = "off",
-- 			description = "Keep all explorer nodes closed on startup",
-- 		},
-- 		{
-- 			name = "all",
-- 			description = "All explorer nodes are opened on startup",
-- 		},
-- 		{
-- 			name = "lastOpened",
-- 			description = "Reopen the nodes that were opened from previous sessions on startup",
-- 		},
-- 	},
-- }

local rememberLastOpenedStory: CheckboxSetting = {
	name = "rememberLastOpenedStory",
	displayName = "Remember last opened story",
	description = "Open the last viewed story when starting",
	settingType = SettingType.Checkbox,
	value = true,
}

local theme: DropdownSetting = {
	name = "theme",
	displayName = "UI theme",
	description = "Select the UI theme to use. By default, Flipbook will use the same theme as Studio",
	settingType = SettingType.Dropdown,
	choices = {
		{
			name = "system",
			description = "Match the theme selected for Studio",
		},
		{
			name = "dark",
			description = "Force the theme to use dark mode",
		},
		{
			name = "light",
			description = "Force the theme to use light mode",
		},
	},
}

local sidebarWidth: NumberSetting = {
	name = "sidebarWidth",
	displayName = "Sidebar panel width",
	description = `The default width (in pixels) of the sidebar. This can be between {constants.SIDEBAR_MIN_WIDTH}-{constants.SIDEBAR_MAX_WIDTH} px`,
	settingType = SettingType.Number,
	range = NumberRange.new(constants.SIDEBAR_MIN_WIDTH, constants.SIDEBAR_MAX_WIDTH),
	value = constants.SIDEBAR_INITIAL_WIDTH,
}

local controlsHeight: NumberSetting = {
	name = "controlsHeight",
	displayName = "Controls panel height",
	description = `The default height (in pixels) of the 'Controls' panel. This can be between {constants.CONTROLS_MIN_HEIGHT}-{constants.CONTROLS_MAX_HEIGHT} px`,
	settingType = SettingType.Number,
	range = NumberRange.new(constants.CONTROLS_MIN_HEIGHT, constants.CONTROLS_MAX_HEIGHT),
	value = constants.CONTROLS_INITIAL_HEIGHT,
}

local settings = {
	-- expandNodesOnStart = expandNodesOnStart,
	rememberLastOpenedStory = rememberLastOpenedStory,
	theme = theme,
	sidebarWidth = sidebarWidth,
	controlsHeight = controlsHeight,
}

export type Settings = typeof(settings)

return settings
