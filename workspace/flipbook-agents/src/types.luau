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

export type AppImplementation = {
	embedFlipbook: (parentPath: string?, overwrite: boolean) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?) -> StoryInfo,
	getCurrentStory: () -> StoryInfo?,
}

export type StoryImplementation = {
	path: string,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
}

export type AgentController = {
	openWidget: () -> (),
	embedFlipbook: (parentPath: string?, overwrite: boolean?) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?) -> StoryInfo,
	getCurrentStory: () -> CurrentStory?,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
	registerApp: (implementation: AppImplementation) -> () -> (),
	registerStory: (implementation: StoryImplementation) -> () -> (),
}

return {}
