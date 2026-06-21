---
aliases: [Getting Started]
linter-yaml-title-alias: Getting Started
---

# Getting Started

Flipbook is a storybook plugin that previews UI components in a sandboxed environment. With it you can isolate distinct parts of your game's UI to hammer out edge cases and complex states without having to run through the whole UI.

By default, Flipbook uses a function-based renderer with support for Roblox Instances to get you up and running, and offers native support for UI libraries like [[usage/frameworks/react|React]] and [[usage/frameworks/fusion|Fusion]]. No matter how you create UI you can write a story for it in Flipbook.

![[main-screenshot.png]]

## Installation

### Creator Store

Install the latest version of Flipbook from the [Creator Store](https://create.roblox.com/store/asset/8517129161/flipbook) and receive updates as new versions are released. A [development version](https://create.roblox.com/store/asset/88523969718241/Flipbook-Dev) of Flipbook is also available. It's built from the `main` branch so expect bugs but we always value early adopters!

### GitHub Releases

Manually install versions of Flipbook from the [GitHub Releases](https://github.com/flipbook-labs/flipbook/releases) page. All releases include an `rbxm` of Flipbook under the "Assets" tab which can be downloaded and copied to Roblox Studio's plugins folder.

## Create Your First Story

A [[concepts/storybook|Storybook]] tells Flipbook where to discover your Stories, and a [[concepts/story|Story]] renders a single component in isolation. You need one of each to see Flipbook working.

A Storybook can be parented anywhere in the experience. The only requirement is that it defines a `storyRoots` array so Flipbook knows where to search for Stories.

The simplest Storybook looks like this:

<!-- code-sample: workspace/code-samples/src/Default/ProjectName.storybook.luau -->

And here's an example of a Story that renders a TextButton:

<!-- code-sample: workspace/code-samples/src/Default/Button.story.luau -->

In the Flipbook plugin, opening the Button story will render out the component.

![[first-story.png]]

From there, making changes to the Story will live-reload the rendered button.

To connect it back to Studio, these files could simply be stored in ReplicatedStorage as ModuleScripts like so:

![[storybook-setup.png]]

You've now rendered your first Story. From here, [[usage/writing-stories|Writing Stories]] goes deeper on Storybooks and Stories and how to write them for your UI framework.
