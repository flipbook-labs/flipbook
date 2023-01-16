local flipbook = script:FindFirstAncestor("flipbook")

local t = require(flipbook.Packages.t)

local types = {}

export type RoactElement = { [string]: any }
export type Roact = {
	createElement: (...any) -> any,
	mount: (...any) -> any,
	unmount: (...any) -> (),
}
types.Roact = t.interface({
	createElement = t.callback,
	mount = t.callback,
	unmount = t.callback,
})

type ReactElement = { [string]: any }

type React = {
	createElement: (...any) -> any,
}
types.React = t.interface({
	createElement = t.callback,
})

type ReactRoblox = {
	createRoot: () -> (),
}
types.ReactRoblox = t.interface({
	createRoot = t.callback,
})

export type StoryProps = {
	controls: { [string]: any },
}

export type StoryFormat = "Roact" | "React" | "Functional" | "Hoarcekat"

export type Storybook = {
	storyRoots: { Instance },

	name: string?,
	roact: Roact?,
	react: React?,
	reactRoblox: ReactRoblox?,
}

types.Storybook = t.interface({
	storyRoots = t.array(t.Instance),

	name = t.optional(t.string),
	roact = t.optional(types.Roact),
	react = t.optional(types.React),
	reactRoblox = t.optional(types.ReactRoblox),
})

export type StoryControl = {
	name: string?,
	type: string?,
	value: any,
}

export type Controls = {
	[string]: StoryControl,
}

export type StoryMeta = {
	name: string,
	summary: string?,
	controls: Controls?,
}

export type RoactStory = StoryMeta & {
	story: RoactElement | (props: StoryProps) -> RoactElement,
	roact: Roact,
}

export type ReactStory = StoryMeta & {
	story: ReactElement | (props: StoryProps) -> ReactElement,
	react: React,
	reactRoblox: ReactRoblox,
}

export type FunctionalStory = StoryMeta & {
	story: (target: GuiObject, props: StoryProps) -> (() -> ())?,
}

export type Story = FunctionalStory | RoactStory | ReactStory

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
