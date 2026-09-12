---
aliases: [Storybook Format]
linter-yaml-title-alias: Storybook Format
---

# Storybook Format

Any ModuleScript with a `.storybook` extension will be picked up as a Storybook.

> [!tip] 💡
> Storybooks that do not have a `storyRoots` array will not be shown in the Flipbook UI.

The properties that can be used in the module are as follows:

| **Property**                                             | **Description**                                                                                                                                                                                                                                                                 |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `storyRoots: { Instance }`                               | Locations that the Storybook manages. Each instance will have its descendants searched for Story modules.                                                                                                                                                                       |
| `name: string?`                                          | An optional name for the Storybook. Defaults to the module name with the extension removed. i.e. `Sample.storybook` becomes `Sample`.                                                                                                                                           |
| `packages: { [string]: any }?`                           | An optional dictionary used for supplying the Storybook with the packages to use when rendering its Stories. <br><br>This dictionary can also be supplied per-Story to change the renderer used, but it can be convenient to define your packages globally to avoid repetition. |
| `mapStory: ((story) -> (props: StoryProps) -> element)?` | Wraps every Story the Storybook renders. See [[api/storybook-format#Wrapping Stories with mapStory\|Wrapping Stories with mapStory]].                                                                                                                                           |
| `mapDefinition: ((story) -> story)?`                     | Transforms each Story definition before it renders. Like `mapStory`, this applies to the React and Roact renderers.                                                                                                                                                             |

Example Storybook module that names itself and configures React for all of its Stories:

```code-sample
workspace/code-samples/src/React/React.storybook.luau
```

## Wrapping Stories with mapStory

`mapStory` lets a Storybook wrap every one of its Stories in shared UI or context, so each Story doesn't have to repeat it. It receives the Story's `story` value and returns a component that renders in its place, with the same [[api/story-props|StoryProps]]. It applies when Stories render with the React or Roact renderer.

This Storybook pads every Story it renders:

```code-sample
workspace/code-samples/src/MapStory/MapStory.storybook.luau
```

Flipbook uses this itself to wrap its own component Stories in the theme and plugin context they expect.

## Legacy Support

> [!warning]
> These properties are a compatibility layer for Flipbook v1, and a future version of Flipbook may remove them. Migrate to `packages`.

Flipbook v1 used a different approach for defining packages. For convenience, v2 provides backwards compatibility for the following Storybook properties:

| **Property**     | **Description**                                                                                                                    |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| fusion: any      | The version of Fusion to use when mounting Fusion components. Maps to `packages.Fusion`.                                           |
| roact: any       | The version of Roact to use when mounting Roact components. Maps to `packages.Roact`.                                              |
| react: any       | The version of React to use when mounting React components. Maps to `packages.React`.                                              |
| reactRoblox: any | The version of ReactRoblox to use when mounting React components. Mutually exclusive with `react`. Maps to `packages.ReactRoblox`. |

Under the hood these simply map to `packages.Fusion`, `packages.Roact`, `packages.React`, and `packages.ReactRoblox`.

> [!seealso]
> [[concepts/storybook|Storybook]]: what a Storybook is and how discovery works
> [[api/story-format|Story Format]] · [[api/story-props|StoryProps]]
