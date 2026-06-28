---
aliases: [Hoarcekat]
linter-yaml-title-alias: Hoarcekat
---

# Hoarcekat

[Hoarcekat](https://github.com/Kampfkarren/hoarcekat/) is a popular storybook plugin like Flipbook. Because of its popularity, its story format is supported by Flipbook so that you have an easier time migrating.

> [!note]
> This guide assumes you are using [Rojo](https://github.com/rojo-rbx/rojo/) to manage your source code. If you are not then your mileage may vary.

## Creating the Storybook

The main difference in how Flipbook and Hoarcekat handle stories is that Flipbook requires a Storybook file to know where your stories live. Create a new `ProjectName.storybook.luau` file at the root of your project:

```code-sample
workspace/code-samples/src/Hoarcekat/Hoarcekat.storybook.luau
```

The `packages` key tells Flipbook which UI library to use when rendering stories in this Storybook. Once this file is in place, the Storybook appears in Flipbook's sidebar and you can open your stories.

> [!tip]
> If you have an older Storybook that uses `roact = Roact` instead of `packages`, that still works, since it maps to `packages.Roact` for backwards compatibility. Prefer `packages` for new Storybooks.

## Migrating Stories

A Hoarcekat story is a module that returns a bare function. The function receives the container Instance and returns an optional cleanup callback:

```code-sample
workspace/code-samples/src/Hoarcekat/HelloWorldLabelBefore.story.luau
```

Flipbook still runs this shape without changes, since the legacy format is automatically detected and handled. But to use Flipbook's controls and other story features, migrate to the standard format: a module returning a table with a `story` function. Because the Storybook already supplies `packages.Roact`, the story no longer needs to mount and unmount the component itself:

```code-sample
workspace/code-samples/src/Hoarcekat/HelloWorldLabel.story.luau
```

From here you can add a `summary`, [[usage/controls|controls]], and anything else from the [[api/story-format|Story Format]].

> [!seealso]
> [[api/story-format|Story Format]] · [[concepts/storybook|Storybook]] · [[usage/writing-stories|Writing Stories]]
