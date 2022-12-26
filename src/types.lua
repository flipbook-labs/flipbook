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
	textSize: number,
	font: Enum.Font,
	headerTextSize: number,
	headerFont: Enum.Font,

	background: Color3,
	sidebar: Color3,
	canvas: Color3,
	scrollbar: Color3,
	button: Color3,
	buttonText: Color3,
	divider: Color3,
	text: Color3,
	textFaded: Color3,
	selection: Color3,
	story: Color3,
	directory: Color3,

	padding: UDim,
	paddingSmall: UDim,
	paddingLarge: UDim,

	corner: UDim,
}

export type ComponentTreeNode = {
	name: string,
	children: { ComponentTreeNode },
	icon: string?,
	instance: Instance?,
	storybook: Storybook?,
}

export type DragHandle = "Top" | "Right" | "Bottom" | "Left"

return {}
