---
aliases: [Story Props]
linter-yaml-title-alias: Story Props
---

# Story Props

A Story's `story` function is passed in a `StoryProps` object that contains the following.

| **Property** | **Type**        | **Description**                                                                     |
| ------------ | --------------- | ----------------------------------------------------------------------------------- |
| `container`  | `Instance`      | The Instance  where each story is rendered to.                                      |
| `theme`      | `string`        | A string representing the current Roblox Studio theme.                              |
| `controls`   | `StoryControls` | Defaults to an empty table.                                                         |
| `locale`     | `string`        | Hardcoded as "en-us" but will be updated to support other localities in the future. |
| `plugin`     | `Plugin`        | A reference to Flipbook's `Plugin` object.                                          |

Example of using `StoryProps`:

```lua title="Sample.story.luau"
return {
	story = function(props)
	
	end
}
```
