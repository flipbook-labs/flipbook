---
aliases: [Storyteller API Synced Block 1]
linter-yaml-title-alias: Storyteller API Synced Block 1
---

# Story Format

Any ModuleScript with a `.story` extension will be picked up as a Story when it is a descendant of one of the `storyRoots` that a Storybook manages.

The only required member of a Story definition is the `story` property.

| **Property**                              | Description                                                                                                                                                                |     |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| `story: <T>((props: StoryProps) -> T): T` |                                                                                                                                                                            |     |
| `name: string?`                           | The name of the Story as it appears in Flipbook. Defaults to the name of the Story module. i.e. `Sample.story` becomes `Sample`                                            |     |
| `summary: string?`                        | A description of the Story that will appear above the rendered preview in Flipbook.                                                                                        |     |
| `controls: { [string]: any }?`            | Controls allow for on-the-fly configuration of your rendered UI. Read more about how to define and use Controls here: [[NOTION_PAGE:12f95b79-12f8-8043-88e1-d746a6617716]] |     |

The type of the `story` property is dependent on what kind of Story is being rendered. Flipbook does not prescribe one particular way of writing Stories, or even a particular UI library that must be used.

Stories can be written for React, Fusion, legacy Roact, plain Roblox Instances, and anything you can think of with [Manual Stories](/12f95b7912f880068da6d74c472bf186#12f95b7912f880fd8f60d63a784e0d78).

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

Flipbook v1 used a different approach for defining packages. For convenience, v2 provides backwards compatibility for the following Storybook properties:

| **Property**     | **Description**                                                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| roact: any       | Locations that the Storybook manages. Each instance will have its descendants searched for Story modules.                             |
| react: any       | An optional name for the Storybook. Defaults to the module name with the extension removed. i.e. `Sample.storybook` becomes `Sample`. |
| reactRoblox: any | The version of ReactRoblox to use when mounting React components. Mutually exclusive with `react`.                                    |

Under the hood these simply map to `packages.Roact`, `packages.React`, and `packages.ReactRoblox`.
