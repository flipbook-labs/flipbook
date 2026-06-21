---
aliases: [2025 Flipbook Product Spec]
linter-yaml-title-alias: 2025 Flipbook Product Spec
---

# 2025 Flipbook Product Spec

## Audience

- Roblox engineers working on the Universal App, in-experience UI, built-in plugins, and any other Luau-based projects with UI
- Creators (Engineers) that use tools like Rojo to sync Roblox Studio
- Creators (Engineers) that work exclusively in Roblox Studio
- Creators (Designers/Product) that want to preview the current UI implementations from in-experience

## What Can Flipbook Do Now?

- Discover Storybook and Story modules in the DataModel
- Render a Story in the plugin
- Render a Story in the experience viewport
- Render React, Roact, Fusion, and GuiObject stories
- Compatibility with Hoarcekat stories
- Open Explorer to the top-most instance that the story renders
- Open story module in the Explorer
- Search for a story/storybook by name
- Resizable panels (Sidebar, Controls)
- Story controls
  - Supports numbers, strings, booleans, and I think that's about it
- User settings
  - Reopen last story between sessions
  - Controls panel height
  - Sidebar panel width
  - UI theme
- Use Storyteller for typesafe storybooks and stories
- Storybooks that fail to load are placed in an Unavailable Storybooks folder where the user can inspect what went wrong

## What Do We Want Flipbook to Be Able to Do?

| **Feature** | **Details** | **Est. (Days)** | **Ticket** | **Status** | **Priority** |
| --- | --- | --- | --- | --- | --- |
| Validate that Colors Contrast Well together for Accessibility | | 14 | [#273](https://github.com/flipbook-labs/flipbook/issues/273) | Not started | P1 |
| Anonymized Usage Metrics | Flipbook's usage is a blackbox. We have no idea how many users we have, if they get stuck anywhere, what the overall sentiment is, etc. | 14 | [#356](https://github.com/flipbook-labs/flipbook/issues/356) | Not started | P1 |
| Basic Substories Support | | 6 | | Done | P0 |
| Report Bugs from Flipbook that Get Posted to GitHub | Hopefully a webhook can make this easy | 5 | [#352](https://github.com/flipbook-labs/flipbook/issues/352) | Not started | P1 |
| Click UI Elements in the Story Preview to Open Them in the Explorer | | 4 | [#347](https://github.com/flipbook-labs/flipbook/issues/347) | Not started | P0 |
| Toolbar with Various Actions that Can Be Dragged to Other Locations on the Screen | Toolbar position is remembered between sessions | 14 | [#357](https://github.com/flipbook-labs/flipbook/issues/357) | Not started | P1 |
| Device Emulator | Includes support for all the devices we listed in the Music 2025 Figma spec | 28 | | Not started | P1 |
| Include Docs Right in the Plugin | | 14 | [#311](https://github.com/flipbook-labs/flipbook/issues/311) | Not started | P2 |
| Use a Dotted Background like Figma and UI Labs Do | | 1 | [#350](https://github.com/flipbook-labs/flipbook/issues/350) | Not started | P1 |
| Dropdown to Select Which Theme to Use Right from the Story | | 3 | [#346](https://github.com/flipbook-labs/flipbook/issues/346) | Not started | P0 |
| Embed into Experience | Embed everything Flipbook needs to run right into the experience so joining a server will be the same as using the plugin | 14 | | Not started | P0 |
| FigJam-style Collaboration | | 21 | [#362](https://github.com/flipbook-labs/flipbook/issues/362) | Not started | P2 |
| Full Compatibility with UI Labs | 1:1 interop with storybooks and stories | 14 | [#348](https://github.com/flipbook-labs/flipbook/issues/348) | Not started | P0 |
| Improved FTUX | | 3 | | Not started | P1 |
| Maximize Story View | Hide all other UI and have the story view take up the full plugin widget; hovering near the top brings the toolbar back | 4 | [#359](https://github.com/flipbook-labs/flipbook/issues/359) | Not started | P2 |
| Measuring Tool | "Oh there's a 4px gap here but in Figma it's 8px" | 4 | [#351](https://github.com/flipbook-labs/flipbook/issues/351) | Not started | P1 |
| Module Loading is Buggy | If something errors in a story or its components the preview can error out and get stuck until reloading the plugin | 7 | | Not started | P0 |
| No Storybook Required | Stories that aren't managed by a storybook will show up under a default storybook | 5 | [#282](https://github.com/flipbook-labs/flipbook/issues/282) | In progress | P0 |
| Pin Favorite Storybooks to the Top | | 5 | [#291](https://github.com/flipbook-labs/flipbook/issues/291) | In progress | P1 |
| Preview GuiObjects by Selecting Them | Select a GuiObject in the DataModel to have Flipbook preview it automatically | 7 | [#353](https://github.com/flipbook-labs/flipbook/issues/353) | Not started | P1 |
| Middleware to Wrap a Story | mapStory | 3 | | Done | P0 |
| Quickly Create Screenshots of the Story in Various Dimensions | | 7 | [#360](https://github.com/flipbook-labs/flipbook/issues/360) | Not started | P2 |
| Story Stack Traces Are a Nightmare | When a story errors, the stacktrace is gigantic and almost entirely useless | 14 | [#349](https://github.com/flipbook-labs/flipbook/issues/349) | Not started | P0 |
| Tabs to Preview and Jump between Stories | | 7 | [#361](https://github.com/flipbook-labs/flipbook/issues/361) | Not started | P2 |
| Studio Mode | By default Flipbook is geared towards filesync workflows; this enables settings more ergonomic for Studio-only Creators | 12 | [#354](https://github.com/flipbook-labs/flipbook/issues/354) | Not started | P1 |
| TeamCreate Enhancements | Show who is viewing which storybook/story in the sidebar | 10 | [#362](https://github.com/flipbook-labs/flipbook/issues/362) | Not started | P2 |
| Zoom In-out on a Story | | 2 | [#358](https://github.com/flipbook-labs/flipbook/issues/358) | Not started | P2 |

TODO: Research StorybookJS' interaction testing and visual testing features. Also addons too

### Why Not Flipbook?

What are the reasons that someone would not want to use Flipbook? The following is a list of issues taken from known user sentiments and from my own observations

- Too hard to get setup — FTUX isn't great. Users need to know how to first create a storybook, point the story roots to the right place, and create properly-formatted story files all before anything shows up in the UI
- Not enough features compared to UI Labs — What's missing, exactly?
- Flipbook should have a previewing mode that plays better with viewport previewing — Hide the widget and place Flipbook's UI directly in the viewport. The story view becomes transparent - Pairs well with an option to hide Flipbook's UI to maximize the story view (see the wishlist)
- The UI Labs author is very active on Discord and engages with the users of the plugin. Users have likely gravitated towards UI Labs in part because of this. We could be doing more to engage with the community

# Packages

## Storyteller

- Discover and return the list of stories that aren't managed by a storybook
- Render stories without a storybook (have some in-memory storybook)
- mapStory as a first-class citizen
  - This needs to be added for Roblox-internal support but being able to run some middleware on every story is handy

# To Add Roblox-internal Support

- Draft PR with a built-in plugin for Flipbook
  - Prebuild Flipbook in StudioPlugins. You don't have to ship this yet, use it for development primarily so you can work out the kinks in a dev enrivonment
- Take a naive stab at removing packages from RobloxPackages that we don't use. The bundle size is gargantuan currently

# Visual Testing

[Visual testing & review for web user interfaces](https://www.chromatic.com/)

# Statement

We should make a statement on our ROSS thread that Flipbook is building momentum
