# Writing Stories

Before Flipbook can discover your Stories, you need a Storybook. A Storybook is any ModuleScript with a `.storybook` extension. It acts as the topmost configuration for each collection of Stories in your project.

Relatedly, a Story is any ModuleScript with a `.story` extension, typically parented as a sibling to the UI component it renders.

Stories are what you will be working with the most. The Storybook is simply what tells Flipbook how to find them and render them.

## Getting started

A Storybook can be parented anywhere in the experience. The only requirement is that it defines a `storyRoots` array so Flipbook knows where to search for Stories.

The simplest Storybook looks like this:

<<< @/../../workspace/code-samples/src/Default/ProjectName.storybook.luau

And here's an example of a Story that renders a TextButton:

<<< @/../../workspace/code-samples/src/Default/Button.story.luau

In the Flipbook plugin, opening the Button story will render out the component.

![Rendering the Button story in Flipbook's UI](./img/first-story.png)

From there, making changing to the Story will live-reload the rendered button.

To connect it back to Studio, these files could simply be stored in ReplicatedStorage as ModuleScripts like so:
![Screenshot of Studio showing the hierarchy of ReplicatedStorage](./img/storybook-setup.png)

## Using frameworks

By default, Flipbook uses a function-based renderer with support for Roblox Instances to get you up and running. Simply returning an Instance allows Flipbook to manage the creation and destruction of that Instance so you don't leak memory while working.

Flipbook also has built-in support for UI libraries like [React](../frameworks/react) and [Fusion](../frameworks/fusion).

You can tell Flipbook to use a particular UI library by passing in the `packages` object. Here's an example with React:

<<< @/../../workspace/code-samples/src/React/ReactButtonExplicitPackages.story.luau

It can be tedious to supply the `packages` object in each Story module, which is why it is more common to add them globally in the Storybook so that all Stories can render with the UI library you use across your project.

The following example splits out the body of the story to a ReactButton component and offloads the definition of `packages` to the Storybook:

<<< @/../../workspace/code-samples/src/React/ReactButton.luau

<<< @/../../workspace/code-samples/src/React/ReactButton.story.luau

<<< @/../../workspace/code-samples/src/React/React.storybook.luau

:::tip
Stories can individually override the global `packages` so if you need to use another UI library for a particular Story, you can do that.
:::
