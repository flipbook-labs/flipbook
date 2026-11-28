export type Controls = { [string]: unknown }

export type StorybookInfo = {
	name: string,
	path: string,
}

export type StoryInfo = {
	name: string,
	path: string,
	storybook: string?,
}

export type CurrentStory = StoryInfo & {
	isMounted: boolean,
}

export type AppAdapter = {
	embedFlipbook: (parentPath: string?, overwrite: boolean) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string?) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?) -> StoryInfo,
	getCurrentStory: () -> StoryInfo?,
}

export type StoryAdapter = {
	path: string,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
}

-- Moves the plugin's app between its widget and the Edit-mode viewport. Embedded
-- Flipbook has no widget, so it doesn't provide one.
export type MovableSurface = {
	isVisible: () -> boolean,
	openViewport: () -> (),
	openWidget: () -> (),
}

export type AgentActions = {
	openWidget: () -> (),
	openViewport: () -> (),
	embedFlipbook: (parentPath: string?, overwrite: boolean?) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string?) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?) -> StoryInfo,
	getCurrentStory: () -> CurrentStory?,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
}

export type AgentController = AgentActions & {
	registerApp: (adapter: AppAdapter) -> () -> (),
	registerStory: (adapter: StoryAdapter) -> () -> (),
}

return nil
