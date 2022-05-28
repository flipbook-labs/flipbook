export type RoactElement = { [string]: any }

export type Storybook = {
	storyRoots: { Instance },
	name: string?,
	roact: any,
}

export type StoryControl = {
	name: string?,
	type: string?,
	value: any,
}

export type Controls = {
	[string]: StoryControl,
}

export type Story = {
	name: string,
	roact: any,
	summary: string?,
	controls: Controls?,
	story: RoactElement | ({ [string]: any }) -> RoactElement,
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
		arrow: Color3,
		folder: Color3,
		search: Color3,
		story: Color3,
	},
	searchbar: {
		background: Color3,
		stroke: Color3,
	},
	explorerEntry: {
		background: Color3,
		selectedBackground: Color3,
		selectedText: Color3,
		text: Color3,
	},
}

return nil
