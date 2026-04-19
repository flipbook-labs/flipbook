---
notion-id: 27695b79-12f8-8196-a043-c16705326573
aliases: [Reference]
linter-yaml-title-alias: Reference
---

Requirements:

- Regular users should never see Roblox stories
  - Either implicitly check for Roblox Internal, or add an explicit setting to the Settings menu to enable the flow

# Reference

1. [roblox.atlassian.net](https://roblox.atlassian.net/wiki/spaces/HOW/pages/1556186059/1005+-+Using+Developer+Storybooks)

# Deviations

Determining the deviations between Developer Storybook and Flipbook’s Storybook and Story formats, and other functionality that’s needed

Relevant documentation for Developer Storybook:

2. [Using Developer Storybooks](https://roblox.atlassian.net/wiki/spaces/HOW/pages/1556186059/1005+-+Using+Developer+Storybooks)
3. [Story API](https://roblox.atlassian.net/wiki/spaces/HOW/pages/1556186305/Story+API)\*\* \*\*

## Storybook Deviations

[Internal Storybook definition](https://roblox.atlassian.net/wiki/spaces/HOW/pages/1556185744/1005.1+-+Creating+a+Minimal+New+Storybook)

4. Inclusion of `roact` and `reactRoblox` on the story/storybook means “render with React”.
   1. We use `react` and `reactRoblox` means React, or `roact` means legacy Roact
5. Only supports React and legacy Roact
6. Substories 😵‍💫
7. Props to support
   ![[assets/Screenshot_2024-11-05_at_9.58.59_AM.png]]
   ![[assets/Screenshot_2024-11-05_at_9.59.16_AM.png]]

## Story Deviations
