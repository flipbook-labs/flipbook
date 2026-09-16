export type Controls = { [string]: unknown }

export type StorybookInfo = {
	name: string,
	path: string,
}

export type StoryInfo = {
	id: string,
	name: string,
	path: string,
	storybook: string?,
}

export type CurrentStory = StoryInfo & {
	controlsReady: boolean,
	isMounted: boolean,
}

export type AppImplementation = {
	embedFlipbook: (parentPath: string?, overwrite: boolean) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?, storyId: string?) -> StoryInfo,
	getCurrentStory: () -> StoryInfo?,
}

export type StoryImplementation = {
	id: string,
	path: string,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
}

export type AgentController = {
	openWidget: () -> (),
	embedFlipbook: (parentPath: string?, overwrite: boolean?) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?, storyId: string?) -> StoryInfo,
	getCurrentStory: () -> CurrentStory?,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
	registerApp: (implementation: AppImplementation) -> () -> (),
	registerStory: (implementation: StoryImplementation) -> () -> (),
}

return {}
