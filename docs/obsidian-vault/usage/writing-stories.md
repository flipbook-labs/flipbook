---
aliases: [Writing Stories]
linter-yaml-title-alias: Writing Stories
---

# Writing Stories

Once you've [[usage/getting-started|rendered your first Story]], this guide covers the two file types in more detail and how to write Stories for your UI framework.

## Storybooks and Stories

A [[concepts/storybook|Storybook]] is any ModuleScript with a `.storybook` extension. It acts as the topmost configuration for each collection of Stories in your project and defines a `storyRoots` array that tells Flipbook where to search for Stories.

A [[concepts/story|Story]] is any ModuleScript with a `.story` extension, typically parented as a sibling to the UI component it renders. Stories are what you will be working with the most. The Storybook is what tells Flipbook how to find and render them.

See [[api/storybook-format|Storybook Format]] and [[api/story-format|Story Format]] for the full module APIs.

## Using Frameworks

By default, Flipbook uses a function-based renderer with support for Roblox Instances to get you up and running. Simply returning an Instance allows Flipbook to manage the creation and destruction of that Instance so you don't leak memory while working.

Flipbook also has built-in support for UI libraries like [[usage/frameworks/react|React]] and [[usage/frameworks/fusion|Fusion]]. The full list can be seen in [[usage/frameworks/index|Frameworks]].

You can tell Flipbook to use a particular UI library by passing in the `packages` object. Here's an example with React:

```code-sample
workspace/code-samples/src/React/ReactButtonExplicitPackages.story.luau
```

It can be tedious to supply the `packages` object in each Story module, which is why it is more common to add them globally in the Storybook so that all Stories can render with the UI library you use across your project.

The following example splits out the body of the story to a ReactButton component and offloads the definition of `packages` to the Storybook:

```code-sample
workspace/code-samples/src/React/ReactButton.luau
```

```code-sample
workspace/code-samples/src/React/ReactButton.story.luau
```

```code-sample
workspace/code-samples/src/React/React.storybook.luau
```

> [!tip]
> Stories can individually override the global `packages` so if you need to use another UI library for a particular Story, you can do that.
