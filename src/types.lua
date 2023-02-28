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

export type Controls = {
	[string]: string | number | boolean,
}
types.Controls = t.map(t.string, t.union(t.string, t.number, t.boolean))

export type StoryProps = {
	controls: Controls,
}

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

export type StoryMeta = {
	name: string,
	summary: string?,
	controls: Controls?,
	roact: Roact?,
	react: React?,
	reactRoblox: ReactRoblox?,
}
types.StoryMeta = t.interface({
	name = t.optional(t.string),
	summary = t.optional(t.string),
	controls = t.optional(types.Controls),
	roact = t.optional(types.Roact),
	react = t.optional(types.React),
	reactRoblox = t.optional(types.ReactRoblox),
	fusion = t.optional(t.any),
})

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

-- Fusion Types
-- https://github.com/Elttob/Fusion
export type SpecialKey = {
	type: "SpecialKey",
	kind: string,
	stage: "self" | "descendants" | "ancestor" | "observer",
	apply: (SpecialKey, value: any, applyTo: Instance, cleanupTasks: { Task }) -> (),
}

export type Task =
	Instance
	| RBXScriptConnection
	| () -> () | { destroy: (any) -> () } | { Destroy: (any) -> () } | { Task }

export type PropertyTable = { [string | SpecialKey]: any }
type Set<T> = { [T]: any }

export type Dependency = {
	dependentSet: Set<Dependent>,
}

export type Dependent = {
	update: (Dependent) -> boolean,
	dependencySet: Set<Dependency>,
}

export type StateObject<T> = Dependency & {
	type: "State",
	kind: string,
}

export type Value<T> = StateObject<T> & {
	kind: "State",
	set: (Value<T>, newValue: any, force: boolean?) -> (),
}

export type Fusion = {
	New: (className: string) -> ((propertyTable: PropertyTable) -> Instance),
	Value: <T>(initialValue: T) -> Value<T>,
}

types.Fusion = t.interface({
	New = t.callback,
	Value = t.callback,
})

return types
