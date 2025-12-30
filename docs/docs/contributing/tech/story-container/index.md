# Story Container

# Problem

1. Consumers of Storyteller shouldn't have to interact with the `render` API directly, or manage the lifecycle themselves. This is currently what Flipbook has to do in `StoryPreview.luau` ([link](https://github.com/flipbook-labs/flipbook/blob/a004ad52d51f3b5ace2dfb855f7adb4bb25e89b5/workspace/flipbook-core/src/Storybook/StoryPreview.luau#L35-L77))
2. Flipbook can't easily pass along arbitrary props like theme or locale to the story function. The original intention was to have Storyteller manage these things, but it makes more sense for Flipbook to handle that state. Storyteller doesn't need to know about the surrounding UI, it just needs to care about what goes into the sandbox

# Solution

Provide a new `Storyteller.StoryContainer` component that handles a story's lifecycle

Inputs:

1. `story: LoadedStory<T>`
2. `controls: StoryControls`
   1. Reminder that `story.controls` defines the controls schema, and this defines which controls have been modified
3. `extraProps: { [string]: any }`
   1. Arbitrary props that get passed along to the story function. Flipbook sets some values on here like `theme` and `locale`,

Outputs:

- Rendered story within the StoryContainer bounds

# Props sources

When rendering a story, the `props` parameter of the story function gets hydrated from the following sources:

1. StoryContainer's `extraProps`
2. A Story definition's `props` field
3. Storyteller's reserved story props and StoryContainer's `controls`

The props are combined together in that same order. As such, a user can provide props that overrides Flipbook's `theme` and `locale`, but cannot override Storyteller's `container`, `controls`, or `story`.

Here's an example of all of these coming together:

```lua
-- Sample.story.luau
return {
	controls = {
		foo = true,
		font = {
			Enum.Font.BuilderSans,
			Enum.Font.GothamBold,
		}
	},
	props = {
		staticMessage = "Hello, World"
	},
	story = function(props)
		print(props)
	end,
}
```

This should output an object that looks like:

```lua
{

	-- Dynamic values provided by Flipbook
	theme = "Dark",
	locale = "en-us",
	-- Arbitrary values from the story's props
	staticMessage = "Hello, World!"
	-- Storyteller's reserved props
	container = Instance,
	story = ...,
	controls = {
		foo = true,
		font = Enum.Font.BuilderSans,
	},
}
```
