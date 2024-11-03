local t = require("@pkg/t")

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
	createRoot: (Instance) -> {
		render: (any, any) -> (),
		unmount: (any) -> (),
	},
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

export type StorybookMeta = {
	storyRoots: { Instance },
	name: string?,
}
types.Storybook = t.interface({
	storyRoots = t.array(t.Instance),

	name = t.optional(t.string),
	roact = t.optional(types.Roact),
	react = t.optional(types.React),
	reactRoblox = t.optional(types.ReactRoblox),
})

export type RoactStorybook = StorybookMeta & {
	roact: Roact,
}
types.RoactStorybook = t.union(
	types.Storybook,
	t.interface({
		roact = t.optional(types.Roact),
	})
)

export type ReactStorybook = StorybookMeta & {
	react: React,
	reactRoblox: ReactRoblox,
}
types.ReactStorybook = t.union(
	types.Storybook,
	t.interface({
		react = t.optional(types.React),
		reactRoblox = t.optional(types.ReactRoblox),
	})
)

export type Storybook = RoactStorybook | ReactStorybook | StorybookMeta

export type StoryMeta = {
	name: string,
	story: any,
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

export type Story = FunctionalStory | RoactStory | ReactStory | StoryMeta

return types
