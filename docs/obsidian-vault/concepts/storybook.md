---
aliases: [Storybook]
linter-yaml-title-alias: Storybook
---

# Storybook

A Storybook is the map that tells Flipbook where your [Stories](./story.md) live. It's a [ModuleScript](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) with a `.storybook` extension that returns a table with a `storyRoots` array naming the locations whose descendants Flipbook searches for `.story` modules:

```code-sample
workspace/code-samples/src/Default/ProjectName.storybook.luau
```

Point `storyRoots` at any instances you like, and Flipbook walks their descendants, listing every `.story` module it finds underneath that Storybook in the tree. A Storybook with no `storyRoots` array isn't shown in the Flipbook UI, since there's nothing for it to surface.

## What a Storybook Configures

Beyond discovery, a Storybook holds the configuration its Stories share, so you set it once rather than repeating it in every Story:

- `packages`: the UI library used to render Stories (React, Fusion, or Roact). Defining it here means every Story under the Storybook renders with it, and an individual Story can still override `packages` when it needs a different renderer. See [Writing Stories](../usage/writing-stories.md).
- `name`: what the Storybook is called in the tree. Defaults to the module name with the extension stripped, so `Sample.storybook` becomes `Sample`.

See [Storybook Format](../api/storybook-format.md) for the full list of properties.

## Storybooks and Stories

The split is deliberate: a Story describes one piece of UI, while the Storybook says where Stories are and how to render them. Keeping discovery and configuration in one place is what lets a Story stay focused on the component it renders.

A Story that no Storybook covers still appears. Flipbook surfaces it under an "Unavailable Stories" folder. See [Stories Without a Storybook](./story.md#stories-without-a-storybook) for what that means in practice.

> [!seealso]
> [Storybook Format](../api/storybook-format.md): the full module API
> [Story](./story.md) · [Writing Stories](../usage/writing-stories.md)
