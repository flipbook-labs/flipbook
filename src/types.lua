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
	name: string,
	roact: any,
	summary: string?,
	controls: { [string]: StoryControl }?,
	story: RoactElement | (Dictionary<any>) -> RoactElement,
	format: string?,
}

-- Hoarcekat stories are functions that take a GuiObject to mount to and return
-- another function which acts as the cleanup step.
export type HoarcekatStory = (GuiObject) -> () -> ()

export type Theme = {
	background: Color3,
	stroke: Color3,
	text: Color3,
	storybookEntry: Color3,
	icons: {
		search: Color3,
		folder: Color3,
		story: Color3,
	},
	searchbar: {
		background: Color3,
		stroke: Color3,
	},
	entry: {
		background: Color3,
		selectedBackground: Color3,
		selectedText: Color3,
		text: Color3,
	},
}

return nil
