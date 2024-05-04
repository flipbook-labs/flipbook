export type Setting<T> = {
	name: string,
	displayName: string,
	description: string,
	value: T,
}

local expandNodesOnStart: Setting<"Always" | "Never" | "LastOpened"> = {
	name = "expandNodesOnStart",
	displayName = "Expand nodes on start",
	description = "Re-open the storybooks and folders from before",
	value = "RememberLast",
}

local rememberLastOpenedStory: Setting<boolean> = {
	name = "rememberLastOpenedStory",
	displayName = "Remember last opened story",
	description = "Open the last viewed story when starting",
	value = true,
}

local settings = {
	expandNodesOnStart = expandNodesOnStart,
	rememberLastOpenedStory = rememberLastOpenedStory,
}

export type Settings = typeof(settings)

return settings
