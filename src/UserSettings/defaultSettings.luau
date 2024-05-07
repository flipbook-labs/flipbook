export type SettingType = "checkbox" | "dropdown"

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

export type Setting = CheckboxSetting | DropdownSetting

local expandNodesOnStart: Setting = {
	name = "expandNodesOnStart",
	displayName = "Expand nodes on start",
	description = "Re-open the storybooks and folders from before",
	settingType = "dropdown",
	choices = {
		{
			name = "off",
			description = "Keep all explorer nodes closed on startup",
		},
		{
			name = "all",
			description = "All explorer nodes are opened on startup",
		},
		{
			name = "lastOpened",
			description = "Reopen the nodes that were opened from previous sessions on startup",
		},
	},
}

local rememberLastOpenedStory: Setting = {
	name = "rememberLastOpenedStory",
	displayName = "Remember last opened story",
	description = "Open the last viewed story when starting",
	settingType = "checkbox",
	value = true,
}

local theme: Setting = {
	name = "theme",
	displayName = "UI theme",
	description = "Select the UI theme to use. By default, flipbook will use the same theme as Studio",
	settingType = "dropdown",
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

local settings = {
	-- expandNodesOnStart = expandNodesOnStart,
	-- rememberLastOpenedStory = rememberLastOpenedStory,
	theme = theme,
}

export type Settings = typeof(settings)

return settings
