local Storyteller = require("@pkg/Storyteller")

local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")

type StoryControls = Storyteller.StoryControls
type StoryControlsStore = createStoryControlsStore.StoryControlsStore

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
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?) -> StoryInfo,
	getCurrentStory: () -> StoryInfo?,
}

export type StoryImplementation = {
	path: string,
	controlsStore: StoryControlsStore,
}

export type AgentController = {
	openWidget: () -> (),
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?) -> StoryInfo,
	getCurrentStory: () -> CurrentStory?,
	getControls: () -> StoryControls,
	setControls: (controls: { [string]: unknown }) -> StoryControls,
	registerApp: (implementation: AppImplementation) -> () -> (),
	registerStory: (implementation: StoryImplementation) -> () -> (),
}

return {}
