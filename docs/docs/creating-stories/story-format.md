# Story Format

## Storybook

Any ModuleScript with a `.storybook` extension will be picked up as a Storybook.

:::warning
Storybooks that do not have a `storyRoots` array will not be shown in the flipbook UI.
:::

The properties that can be used in the module are as follows:

| **Property** | **Type**             | **Description**                                                                                                                       |
| ------------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `storyRoots` | `{ Instance }`       | Locations that the Storybook manages. Each instance will have its descendants searched for Story modules.                             |
| `name`       | `string?`            | An optional name for the Storybook. Defaults to the module name with the extension removed. i.e. `Sample.storybook` becomes `Sample`. |
| `packages`   | `{ [string]: any }?` | An optional dictionary used for supplying the Storybook with the packages to use when rendering its Stories.                          |

This dictionary can also be supplied per-Story to change the renderer used, but it can be convenient to define your packages globally to avoid repetition. |

Example Storybook module:

```lua
-- Sample.storybook
return {
    storyRoots = {
        script.Parent.Components
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
| `controls`   | `{ [string]: any }?`            | Controls allow for on-the-fly configuration of your rendered UI. Read more about how to define and use Controls here: [Controls](https://www.notion.so/Controls-12f95b7912f8804388e1d746a6617716?pvs=21)                                     |
| `packages`   | `{ [string]: any }?`            | An optional dictionary used for supplying the Story with the packages to use when rendering. The Story inherits the packages defined by the Storybook, so this is mostly used in cases where  Story needs to deviate from the usual renderer |

The type of the `story` property is dependent on what kind of Story is being rendered. flipbook does not prescribe one particular way of writing Stories, or even a particular UI library that must be used.

Stories can be written for React, Fusion, legacy Roact, plain Roblox Instances, and anything you can think of with [Manual Stories](https://www.notion.so/Story-format-12f95b7912f880068da6d74c472bf186?pvs=21).

Example Story module:

```lua
return {
    story = function(props)

    end
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
