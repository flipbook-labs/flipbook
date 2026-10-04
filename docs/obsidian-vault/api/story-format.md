---
aliases: [Story Format]
linter-yaml-title-alias: Story Format
---

# Story Format

Any ModuleScript with a `.story` extension will be picked up as a Story when it is a descendant of one of the `storyRoots` that a Storybook manages.

The only required member of a Story definition is the `story` property.

| **Property**                           | **Description**                                                                                                                                                                                                                      |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `story: T \| (props: StoryProps) -> T` | **Required.** What to render. Either a value Flipbook renders directly (a Roblox Instance, or a framework component/element) or a function that receives [[api/story-props\|StoryProps]] and returns one.                            |
| `name: string?`                        | The name of the Story as it appears in Flipbook. Defaults to the name of the Story module. i.e. `Sample.story` becomes `Sample`.                                                                                                     |
| `summary: string?`                     | A description of the Story that will appear above the rendered preview in Flipbook.                                                                                                                                                  |
| `controls: { [string]: any }?`         | Controls allow for on-the-fly configuration of your rendered UI. Read more about how to define and use them in [[usage/controls\|Controls]].                                                                                         |
| `packages: { [string]: any }?`         | An optional dictionary used for supplying the Story with the packages to use when rendering. The Story inherits the packages defined by the Storybook, so this is mostly used when a Story needs to deviate from the usual renderer. |

The type of the `story` property depends on what kind of Story is being rendered. Flipbook does not prescribe one particular way of writing Stories, or even a particular UI library that must be used.

Stories can be written for React, Fusion, legacy Roact, plain Roblox Instances, and anything you can think of. See [[usage/writing-stories|Writing Stories]] for how the function-based renderer and UI libraries are wired up.

Here is a complete Story that renders a `TextButton` with the default renderer:

```code-sample
workspace/code-samples/src/Default/Button.story.luau
```

## What the Story Function Can Return

When no UI library is configured, Flipbook renders the Story with its default renderer, and a function-based `story` can return either of two things:

- **An Instance.** Flipbook parents it to the Story's container automatically if you haven't parented it yourself.
- **A cleanup function.** Build your UI inside the story function, parent it to `props.container`, and return a function that tears it down. Flipbook calls it when the Story unmounts or re-renders:

```code-sample
workspace/code-samples/src/Default/ButtonWithCleanup.story.luau
```

A story function that declares two or more parameters is called with `(container, props)` instead of `(props)`, which keeps Hoarcekat-style stories working unchanged. See [[usage/migration-guides/migrating-hoarcekat|Migrating from Hoarcekat]].

When the Storybook or Story configures a UI library via `packages`, the story function returns that library's element type instead. See [[usage/frameworks/index|Frameworks]].

## Legacy Support

> [!warning]
> These properties are a compatibility layer for Flipbook v1, and a future version of Flipbook may remove them. Migrate to `packages`.

Flipbook v1 used a different approach for defining packages. For convenience, v2 provides backwards compatibility for the following properties, which map onto `packages`:

| **Property**       | **Description**                                                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `roact: any`       | The version of Roact to use when mounting Roact components. Maps to `packages.Roact`.                                              |
| `react: any`       | The version of React to use when mounting React components. Maps to `packages.React`.                                              |
| `reactRoblox: any` | The version of ReactRoblox to use when mounting React components. Mutually exclusive with `react`. Maps to `packages.ReactRoblox`. |

> [!seealso]
> [[concepts/story|Story]]: what a Story is and how it renders
> [[api/story-props|StoryProps]] · [[api/storybook-format|Storybook Format]]
