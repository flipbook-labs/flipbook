---
aliases: [The Flipbook Interface]
linter-yaml-title-alias: The Flipbook Interface
---

# The Flipbook Interface

Flipbook opens as a single panel split into three areas: the sidebar on the left, the canvas in the middle, and the topbar across the top. A [Controls](./controls.md) panel appears below the canvas when the open Story defines controls. This page walks through each area and what you can do from it.

<!-- capture {
  "asset": "assets/interface-overview.png",
  "kind": "plugin",
  "story": "workspace/code-samples/src/React/ReactButtonControls.story.luau",
  "setup": ["open the ReactButtonControls story so the canvas and controls panel are populated"],
  "frame": "plugin-window",
  "theme": "dark",
  "alt": "The Flipbook plugin window showing the sidebar, canvas, topbar, and controls panel"
} -->

## The Sidebar

The sidebar lists every [Storybook](../concepts/storybook.md) Flipbook found and the [Stories](../concepts/story.md) underneath each one. Selecting a Story renders it in the canvas.

A search box sits at the top. Type into it to filter the tree to matching Stories and Storybooks. Separate terms with `|` to show matches for any term, such as `Button|Dialog`. A Story that no Storybook covers still appears, grouped under an "Unknown Stories" folder, and won't preview until a Storybook covers it (see [Storybook](../concepts/storybook.md)).

Drag the sidebar's right edge to resize it. The width is remembered between sessions, and you can set a default in [Settings](./the-flipbook-interface.md#settings).

<!-- capture {
  "asset": "assets/interface-sidebar-search.png",
  "kind": "plugin",
  "story": "workspace/code-samples/src/React/ReactButtonControls.story.luau",
  "setup": ["type a term into the sidebar search box so the tree filters"],
  "frame": "plugin-window",
  "theme": "dark",
  "alt": "The sidebar with the search box filtering the Story tree"
} -->

## The Canvas

The canvas renders the selected Story on its own, isolated from the rest of your game. Editing the Story reloads the preview, so you can shape a component and see the result without reopening it.

The zoom controls in the topbar scale the canvas up and down, which helps when you are working on something small or want to see a large surface in full.

## The Topbar

The topbar holds the actions for the open Story on the left and Flipbook's support actions on the right.

The Story actions are:

- **Zoom In** and **Zoom Out**: scale the canvas.
- **View Source Code**: open the Story's module in the Script Editor.
- **Preview in Viewport**: render the Story into the 3D viewport instead of the plugin canvas. This action is available when Flipbook runs as a Studio plugin, not when it is [embedded in an experience](./embedding-flipbook.md).
- **View in Explorer**: select the Story's container in the Studio Explorer.
- **Theme**: choose System, Dark, or Light. System matches Studio's theme.

The support actions are:

- **Embed into Experience**: add the Flipbook runtime to the current place so you can open your Storybooks while playing. See [Embedding Flipbook](./embedding-flipbook.md).
- **Help**: open the About dialog, send feedback, or view the Logs.
- **Settings**: open the Settings screen.

## Settings

The Settings screen groups the options Flipbook remembers between sessions.

| Setting                        | Group     | Description                                                          |
| ------------------------------ | --------- | -------------------------------------------------------------------- |
| **UI theme**                   | UI        | The theme Flipbook uses. Defaults to matching Studio.                |
| **Sidebar panel width**        | UI        | Default sidebar width in pixels, between 140 and 500.                |
| **Controls panel height**      | UI        | Default height of the Controls panel in pixels, between 100 and 400. |
| **Remember last opened story** | Stories   | Reopen the last viewed Story when Flipbook starts.                   |
| **Anonymous usage data**       | Telemetry | Send anonymous usage data to help improve Flipbook.                  |

<!-- capture {
  "asset": "assets/interface-settings.png",
  "kind": "plugin",
  "story": "workspace/code-samples/src/React/ReactButtonControls.story.luau",
  "setup": ["click the Settings button in the topbar to open the Settings screen"],
  "frame": "plugin-window",
  "theme": "dark",
  "alt": "The Flipbook Settings screen showing the UI, Stories, and Telemetry groups"
} -->

### Anonymous Usage Data

Flipbook can send anonymous usage data to help the maintainers see which features get used. No personal data or Story content is collected. The setting is on by default and you can turn it off at any time from the Telemetry group.

> [!seealso]
> [Controls](./controls.md): configure a Story from the panel below the canvas
> [Embedding Flipbook](./embedding-flipbook.md) · [Storybook](../concepts/storybook.md)
