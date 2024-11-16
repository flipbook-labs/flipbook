# Story Format

## Storybook

Any ModuleScript with a `.storybook` extension will be picked up as a Storybook.

The properties that can be used in the module are as follows:

| **Property** | **Type**             | **Description**                                                                                                                       |
| ------------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `storyRoots` | `{ Instance }`       | Locations that the Storybook manages. Each instance will have its descendants searched for Story modules.                             |
| `name`       | `string?`            | An optional name for the Storybook. Defaults to the module name with the extension removed. i.e. `Sample.storybook` becomes `Sample`. |
| `packages`   | `{ [string]: any }?` | An optional dictionary used for supplying the Storybook with the packages to use when rendering its Stories.                          |

This dictionary can also be supplied per-Story to change the renderer used, but it can be convenient to define your packages globally to avoid repetition.

The most basic Storybook module can be represented as:

```lua title="Plain.storybook.luau"
return {
    storyRoots = {
        script.Parent,
    },
}
```

## Story

Any ModuleScript with a `.story` extension will be picked up as a Story when it is a descendant of one of the `storyRoots` that a Storybook manages.

The only required member of a Story definition is the `story` property.

| **Property** | **Type**                        | **Description**                                                                                                                                                                                                                              |
| ------------ | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `story`      | `<T>((props: StoryProps) -> T)` |                                                                                                                                                                                                                                              |
| `name`       | `string?`                       | The name of the Story as it appears in flipbook. Defaults to the name of the Story module. i.e. `Sample.story` becomes `Sample`                                                                                                              |
| `summary`    | `string?`                       | A description of the Story that will appear above the rendered preview in flipbook.                                                                                                                                                          |
| `controls`   | `{ [string]: any }?`            | Controls allow for on-the-fly configuration of your rendered UI. Read more about how to define and use controls [here](/docs/creating-stories/controls).                                                                                     |
| `packages`   | `{ [string]: any }?`            | An optional dictionary used for supplying the Story with the packages to use when rendering. The Story inherits the packages defined by the Storybook, so this is mostly used in cases where  Story needs to deviate from the usual renderer |

The type of the `story` property is dependent on what kind of Story is being rendered. flipbook does not prescribe one particular way of writing Stories, or even a particular UI library that must be used.

## StoryProps

A Story's `story` function is passed in a `StoryProps` object that contains the following.

| **Property** | **Type**        | **Description**                                        |
| ------------ | --------------- | ------------------------------------------------------ |
| `container`  | `Instance`      |                                                        |
| `theme`      | `string`        | A string representing the current Roblox Studio theme. |
| `controls`   | `StoryControls` | Defaults to an empty table.                            |

Example of using `StoryProps`:

```lua title="Sample.story.luau"
return {
	story = function(props)
}
```

## Legacy package support

:::warning
A future version of flipbook may remove this compatibility layer. It is recommended to migrate to `packages` in the meantime.
:::

In flipbook v1, UI libraries were supplied by attaching them as properties to a Story or Storybook. This has been superseded by the `packages` dictionary, which acts as a dedicated location to supply the packages used for rendering Stories.

For backwards compatibility, the following properties are migrated to their `packages` equivalent:

| **Property**  | **Mapping**            |
| ------------- | ---------------------- |
| `fusion`      | `packages.Fusion`      |
| `react`       | `packages.React`       |
| `reactRoblox` | `packages.ReactRoblox` |
| `roact`       | `packages.Roact`       |
