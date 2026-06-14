---
aliases: [Storybook Format]
linter-yaml-title-alias: Storybook Format
---

# Storybook Format

> [!seealso] See also: [[concepts/storybook|Storybook concept]] · [[api/story-format|Story Format]]

Any ModuleScript with a `.storybook` extension will be picked up as a Storybook.

> [!tip] 💡
> Storybooks that do not have a `storyRoots` array will not be shown in the Flipbook UI.

The properties that can be used in the module are as follows:

| **Property**                   | **Description**                                                                                                                                                                                                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `storyRoots: { Instance }`     | Locations that the Storybook manages. Each instance will have its descendants searched for Story modules.                                                                                                                                                                       |
| `name: string?`                | An optional name for the Storybook. Defaults to the module name with the extension removed. i.e. `Sample.storybook` becomes `Sample`.                                                                                                                                           |
| `packages: { [string]: any }?` | An optional dictionary used for supplying the Storybook with the packages to use when rendering its Stories. <br><br>This dictionary can also be supplied per-Story to change the renderer used, but it can be convenient to define your packages globally to avoid repetition. |

Example Storybook module:

```lua
-- Sample.storybook
return {
	storyRoots = {
		script.Parent.Components
	},
}
```

## Legacy Support

Flipbook v1 used a different approach for defining packages. For convenience, v2 provides backwards compatibility for the following Storybook properties:

> [!tip] 💡
> A future version of Flipbook may remove this compatibility layer. It is recommended to migrate to `packages`.

| **Property**     | **Description**                                                                                                                    |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| fusion: any      | The version of Fusion to use when mounting Fusion components. Maps to `packages.Fusion`.                                           |
| roact: any       | The version of Roact to use when mounting Roact components. Maps to `packages.Roact`.                                              |
| react: any       | The version of React to use when mounting React components. Maps to `packages.React`.                                              |
| reactRoblox: any | The version of ReactRoblox to use when mounting React components. Mutually exclusive with `react`. Maps to `packages.ReactRoblox`. |

Under the hood these simply map to `packages.Roact`, `packages.React`, and `packages.ReactRoblox`.
