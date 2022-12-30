local flipbook = script:FindFirstAncestor("flipbook")

local t = require(flipbook.Packages.t)

local types = {}

export type StoryProps = {
	controls: { [string]: any },
}

export type Storybook = {
	storyRoots: { Instance },
	name: string?,
	roact: any,
}

types.Storybook = t.strictInterface({
	storyRoots = t.array(t.Instance),

	name = t.optional(t.string),
	roact = t.optional(t.table),
})

export type StoryControl = {
	name: string?,
	type: string?,
	value: any,
}

export type Controls = {
	[string]: StoryControl,
}

export type RoactElement = { [string]: any }
export type ReactElement = { [string]: any }

export type StoryMeta = {
	name: string?,
	summary: string?,
	controls: Controls?,
}

export type RoactStory = StoryMeta & {
	story: (props: StoryProps) -> RoactElement,
	roact: {
		createElement: (...any) -> any,
		mount: (...any) -> any,
		unmount: (...any) -> (),
	},
}

types.RoactStory = t.interface({
	story = t.union(t.table, t.callback),
	roact = t.interface({
		createElement = t.callback,
		mount = t.callback,
	}),

	name = t.optional(t.string),
	summary = t.optional(t.string),
	controls = t.optional(t.table),
})

export type FunctionalStory = StoryMeta & {
	story: (target: GuiObject, props: StoryProps) -> (() -> ())?,
}

types.FunctionalStory = t.interface({
	story = t.callback,

	name = t.optional(t.string),
	summary = t.optional(t.string),
	controls = t.optional(t.table),
})

export type HoarcekatStory = (target: GuiObject, props: StoryProps) -> (() -> ()?)

types.HoarcekatStory = t.callback

export type Story = RoactStory | FunctionalStory | HoarcekatStory

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

return types
