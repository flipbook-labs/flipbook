local flipbook = script:FindFirstAncestor("flipbook")

local t = require(flipbook.Packages.t)

local types = {}

export type Renderer = { [string]: any }
types.Renderer = t.map(t.string, t.any)

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

export type ReactElement = { [string]: any }
export type React = {
	createElement: (...any) -> any,
}

types.React = t.interface({
	createElement = t.callback,

	-- Roact doesn't have these keys so we use them to differentiate the two
	useCallback = t.callback,
	useEffect = t.callback,
})

export type StoryProps = {
	controls: { [string]: any },
}

export type StoryFormat = "Roact" | "React" | "Functional" | "Hoarcekat"

export type Storybook = {
	storyRoots: { Instance },
	name: string?,

	-- The `roact` prop is deprecated. Use `renderer` for new work
	roact: Roact?,
	renderer: Renderer?,
}

types.Storybook = t.interface({
	storyRoots = t.array(t.Instance),

	name = t.optional(t.string),
	roact = t.optional(types.Roact),
	renderer = t.optional(types.Renderer),
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

	-- The `roact` prop is deprecated. Use `renderer` for new work
	roact: Roact?,
	renderer: Renderer?,
}

export type RoactStory = StoryMeta & {
	story: RoactElement | (props: StoryProps) -> RoactElement,
	renderer: Roact,
}

export type ReactStory = StoryMeta & {
	story: ReactElement | (props: StoryProps) -> ReactElement,
	renderer: React,
}

export type FunctionalStory = StoryMeta & {
	story: (target: GuiObject, props: StoryProps) -> (() -> ())?,
}

export type Story = FunctionalStory | RoactStory

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
