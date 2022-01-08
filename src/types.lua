export type RoactElement = Dictionary<any>

export type Storybook = {
	storyRoots: { Instance },
	name: string?,
}

export type StoryControl = {
	name: string?,
	type: string?,
	value: any,
}

export type Story = {
	name: string?,
	summary: string?,
	controls: { [string]: StoryControl },
	story: RoactElement | (Dictionary<any>) -> RoactElement,
}

-- Legacy stories are functions that take a GuiObject to mount to and return
-- another function which acts as the cleanup step.
export type LegacyStory = (target: GuiObject) -> () -> nil

return nil
