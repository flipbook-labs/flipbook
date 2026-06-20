---
aliases: [Create a Flipbook Package]
linter-yaml-title-alias: Create a Flipbook Package
notion-id: de72c908-05f4-4503-90c4-3a6bd7fb82bb
base: "[[proposals.base]]"
Author:
  - Marin Minnerly
Tags: []
Status: Not started
Created: 2023-12-11T20:39:00
Approval: Drafting
---

# Create a Flipbook Package

The idea is all of our storybook and story-related functionality and types to be exposed off of a public API that creators could import via Wally.

One of the primary benefits would be to allow type-checking within storybook and story files. For example:

```lua
-- Foo.storybook.lua
local flipbook = require(Path.To.Packages.flipbook)

local storybook: flipbook.Storybook = {
    storyRoots = true -- analysis error
}

return storybook

```

```lua
-- Bar.story.lua
local flipbook = require(Path.To.Packages.flipbook)

local story: flipbook.Story = {
    -- TODO: show analysis error
}

return story

```

## Proposed API

### Types

```lua
export type Controls = {
	[string]: string | number | boolean,
}

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

export type StoryMeta = {
	name: string,
	summary: string?,
	controls: Controls?,
	roact: Roact?,
	react: React?,
	reactRoblox: ReactRoblox?,
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

```

### Functions

`isStoryModule(instance: Instance): boolean`

`isStorybookModule(instance Instance boolean`

`useStorybooks(): { Storybook }`
