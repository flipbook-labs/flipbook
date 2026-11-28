local StoryStatus = require("@root/StoryStatus")

export type Controls = { [string]: unknown }

export type StorybookInfo = {
	name: string,
	path: string,
}

export type StoryStatus = StoryStatus.StoryStatus

--[[
	One Story, or one Story module whose Stories aren't known yet. A module
	that is still loading reports `status = "Loading"`, and one that failed
	reports `status = "Unavailable"` with the reason in `problem`. Neither has
	an `id` unless a Story was asked for by id.
]]
export type StoryInfo = {
	id: string?,
	name: string,
	path: string,
	storybook: string?,
	status: StoryStatus,
	problem: string?,
}

export type CurrentStory = StoryInfo & {
	isMounted: boolean,
}

export type AppAdapter = {
	embedFlipbook: (parentPath: string?, overwrite: boolean) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string?) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?, storyId: string?) -> StoryInfo,
	getCurrentStory: () -> StoryInfo?,
}

export type StoryAdapter = {
	id: string,
	path: string,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
}

export type AgentActions = {
	openWidget: () -> (),
	embedFlipbook: (parentPath: string?, overwrite: boolean?) -> string,
	listStorybooks: () -> { StorybookInfo },
	listStories: (storybookPath: string?) -> { StoryInfo },
	openStory: (storyPath: string, storybookPath: string?, storyId: string?) -> StoryInfo,
	getCurrentStory: () -> CurrentStory?,
	getControls: () -> Controls,
	setControls: (controls: Controls) -> Controls,
}

export type AgentController = AgentActions & {
	registerApp: (adapter: AppAdapter) -> () -> (),
	registerStory: (adapter: StoryAdapter) -> () -> (),
}

return nil
