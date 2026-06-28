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

Example Story module:

```lua
return {
	story = function(props)

	end
}
```

## Legacy Support

> [!tip] 💡
> A future version of Flipbook may remove this compatibility layer. It is recommended to migrate to `packages`.

Flipbook v1 used a different approach for defining packages. For convenience, v2 provides backwards compatibility for the following properties, which map onto `packages`:

| **Property**       | **Description**                                                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `roact: any`       | The version of Roact to use when mounting Roact components. Maps to `packages.Roact`.                                              |
| `react: any`       | The version of React to use when mounting React components. Maps to `packages.React`.                                              |
| `reactRoblox: any` | The version of ReactRoblox to use when mounting React components. Mutually exclusive with `react`. Maps to `packages.ReactRoblox`. |

> [!seealso] See also: [[concepts/story|Story concept]] · [[api/story-props|StoryProps]] · [[api/storybook-format|Storybook Format]]
