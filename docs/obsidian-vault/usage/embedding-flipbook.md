---
aliases: [Embedding Flipbook]
linter-yaml-title-alias: Embedding Flipbook
---

# Embedding Flipbook

Flipbook usually runs as a Studio plugin, but you can also embed it into an experience so it runs while the game plays. Anyone who joins the place gets the full Flipbook interface, rendered as in-game UI, and can browse the Storybooks that live in that place. This is how you check a component in the real client, or hand a preview to someone without Studio open.

If you want a dedicated, always-up-to-date preview experience published from CI instead, see [[usage/deploying-storybooks|Deploying Storybooks]]. Embedding is the local, one-click version of the same idea: it puts your installed Flipbook build into the place you have open right now.

## Embed into the Open Place

Click **Embed into Experience** in the [[usage/the-flipbook-interface|topbar]]. The dialog clones Flipbook's runtime into the experience and asks where to parent it. ReplicatedStorage is the default; select another instance in the Explorer to change the destination.

<!-- capture {
  "asset": "assets/embed-dialog.png",
  "kind": "plugin",
  "story": "workspace/code-samples/src/React/ReactButtonControls.story.luau",
  "setup": ["click the Embed into Experience button in the topbar"],
  "frame": "plugin-window",
  "theme": "dark",
  "alt": "The Embed Flipbook into Experience dialog with the destination picker"
} -->

Only one embedded runtime can exist in a place at a time. If one is already there, the dialog shows where it lives and asks whether to overwrite it. After embedding, the new runtime is selected in the Explorer, and playing the experience starts Flipbook.

The embedded copy is a clone of the plugin build you have installed, so after updating Flipbook, embed again to bring the runtime up to date.

## What Happens in Play Mode

When the experience starts, Flipbook creates a `ScreenGui` named `Flipbook` in each player's PlayerGui and mounts its interface there. The embedded server script also turns off character auto-loading, so players spawn without a character and the UI has the screen to itself.

<!-- capture {
  "asset": "assets/embedded-in-experience.png",
  "kind": "external",
  "setup": ["embed Flipbook into a place with the code-samples storybook", "play the experience", "screenshot the Flipbook UI running in the client"],
  "frame": "plugin-window",
  "theme": "dark",
  "alt": "Flipbook running inside a playing experience"
} -->

A few things work differently outside Studio:

- **Preview in Viewport** and **Embed into Experience** are not shown; they only apply when Flipbook runs as a plugin.
- **View Source Code** and the Settings screen depend on Studio, so opening a Story's source does nothing and settings changes are not saved between sessions.

Everything else works as it does in Studio: the sidebar, search, the canvas, and [[usage/controls|Controls]].

## Removing the Embedded Runtime

The runtime is the cloned `Flipbook` instance at the destination you chose, tagged `FlipbookRuntime`. Delete it to remove Flipbook from the experience. Embedding again also offers to overwrite it for you.

> [!seealso]
> [[usage/deploying-storybooks|Deploying Storybooks]]: publish a dedicated preview experience from CI
> [[usage/the-flipbook-interface|The Flipbook Interface]] · [[usage/getting-started|Getting Started]]
