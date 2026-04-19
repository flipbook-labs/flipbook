---
notion-id: 27695b79-12f8-815c-8174-f82e6ca0fbad
aliases: [Audience]
linter-yaml-title-alias: Audience
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

![[Flipbook product wishlist.base]]

TODO: Research StorybookJS' interaction testing and visual testing features. Also addons too

### Why Not Flipbook?

What are the reasons that someone would not want to use Flipbook? The following is a list of issues taken from [known user sentiments](/27695b7912f8812b9efcf61e7251fbae) and from my own observations

- Too hard to get setup
  ![[assets/Screenshot_2024-11-25_at_12.54.14_PM.png]] - FTUX isn't great. Users need to know how to first create a storybook, point the story roots to the right place, and create properly-formatted story files all before anything shows up in the UI
- Not enough features compared to UI Labs
  ![[assets/Screenshot_2024-11-25_at_12.52.35_PM.png]] - What's missing, exactly?
- Flipbook should have a previewing mode that plays better with viewport previewing
  ![[assets/Screenshot_2024-11-25_at_12.59.10_PM.png]] - Hide the widget and place Flipbook's UI directly in the viewport. The story view becomes transparent - Pairs well with an option to hide Flipbook's UI to maximize the story view (see the wishlist)
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
