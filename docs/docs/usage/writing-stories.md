---
sidebar_position: 1
aliases: [Writing Stories]
linter-yaml-title-alias: Writing Stories
---

# Writing Stories

![[concepts/storybook#Storybook]]

![[concepts/story#Story]]

## Getting Started

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

## Using Frameworks

By default, Flipbook uses a function-based renderer with support for Roblox Instances to get you up and running. Simply returning an Instance allows Flipbook to manage the creation and destruction of that Instance so you don't leak memory while working.

Flipbook also has built-in support for UI libraries like [[usage/frameworks/react|React]] and [[usage/frameworks/fusion|Fusion]]. The full list can be seen in [[usage/frameworks/]].

You can tell Flipbook to use a particular UI library by passing in the `packages` object. Here's an example with React:

<!-- code-sample: workspace/code-samples/src/React/ReactButtonExplicitPackages.story.luau -->

It can be tedious to supply the `packages` object in each Story module, which is why it is more common to add them globally in the Storybook so that all Stories can render with the UI library you use across your project.

The following example splits out the body of the story to a ReactButton component and offloads the definition of `packages` to the Storybook:

<!-- code-sample: workspace/code-samples/src/React/ReactButton.luau -->

<!-- code-sample: workspace/code-samples/src/React/ReactButton.story.luau -->

<!-- code-sample: workspace/code-samples/src/React/React.storybook.luau -->

> [!tip]
> Stories can individually override the global `packages` so if you need to use another UI library for a particular Story, you can do that.
