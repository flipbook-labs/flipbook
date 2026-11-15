---
aliases: [Story Props]
linter-yaml-title-alias: Story Props
---

# Story Props

When a Story's `story` property is a function, Flipbook calls it with a single `StoryProps` table containing the following.

| **Property** | **Type**            | **Description**                                                                                                                                                                 |
| ------------ | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `container`  | `Instance`          | Where the Story renders. Parent your UI here when you don't return it from the function.                                                                                        |
| `controls`   | `{ [string]: any }` | The current value of each of the Story's [[usage/controls\|Controls]], keyed by control name. Changing a control re-renders the Story with the new values.                      |
| `theme`      | `"Dark" \| "Light"` | The theme Flipbook is rendering with: Studio's theme, unless overridden in [[usage/the-flipbook-interface#Settings\|Settings]]. Use it to match your UI's colors to the canvas. |
| `locale`     | `string`            | Currently always `"en-us"`.                                                                                                                                                     |
| `plugin`     | `Pluginlike`        | A wrapper around Flipbook's plugin instance. Its methods do nothing when Flipbook is [[usage/embedding-flipbook\|embedded in an experience]].                                   |
| `widget`     | `GuiBase2d`         | The GUI hosting Flipbook's interface. Useful for mounting overlays, like popups and tooltips, that need to escape the Story's container.                                        |

This Story parents its UI to `props.container` instead of returning it, and returns a cleanup function that runs when the Story unmounts:

```code-sample
workspace/code-samples/src/Default/ButtonWithCleanup.story.luau
```

And this one reads `props.controls` to configure what it renders:

```code-sample
workspace/code-samples/src/Default/ButtonWithControls.story.luau
```

> [!seealso]
> [[api/story-format|Story Format]]: the full Story module API
> [[usage/controls|Controls]] · [[usage/writing-stories|Writing Stories]]
