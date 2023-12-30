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
types.Controls = t.map(t.string, t.union(t.string, t.number, t.boolean, t.map(t.number, t.any)))

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
	story: unknown,
	summary: string?,
	controls: Controls?,
	roact: Roact?,
	react: React?,
	reactRoblox: ReactRoblox?,
}
types.StoryMeta = t.interface({
	story = t.any,
	name = t.optional(t.string),
	summary = t.optional(t.string),
	controls = t.optional(types.Controls),
	roact = t.optional(types.Roact),
	react = t.optional(types.React),
	reactRoblox = t.optional(types.ReactRoblox),
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

return types
