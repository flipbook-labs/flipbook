---
aliases: [Troubleshooting]
linter-yaml-title-alias: Troubleshooting
---

# Troubleshooting

When something goes wrong, Flipbook surfaces the error where it happened: a Story that fails to load shows the error in the canvas, and a Storybook that fails to load gets its own error page when you select it. This page covers the messages you are most likely to meet and what they mean.

## "Failed to Load Story"

The Story's module threw when Flipbook required it. The text after `Error:` is the underlying problem, most often a syntax error or a runtime error in the module's top-level code (a bad require path, for example). Use **View Source Code** in the [topbar](./the-flipbook-interface.md) to jump to the module, fix the error, and the preview reloads on save.

## "Story Is Malformed"

The module loaded, but what it returned isn't a valid Story: the table is missing its `story` member, or one of the properties has the wrong type. The end of the message names the property that failed. Compare against the [Story Format](../api/story-format.md).

## "Failed to Load" on a Storybook

Selecting the Storybook shows an error page with the message and the module's source. Either the module threw when required, or its shape is invalid: `storyRoots` must be an array of Instances. Compare against the [Storybook Format](../api/storybook-format.md).

## A Story Doesn't Appear in the Sidebar

Flipbook only lists a Story when both of these hold:

- The module's name ends in `.story` (like `Button.story`).
- It is a descendant of one of the instances in some Storybook's `storyRoots`.

A `.story` module that no Storybook covers still shows up, grouped under an "Unknown Stories" folder, but selecting it doesn't preview it. Flipbook needs a Storybook to render a Story, so add or extend a [Storybook](../concepts/storybook.md) to cover it.

## Anything Else

Open **Help > Logs** in the topbar to see what Flipbook has been doing, and **Help > Send feedback** to report a problem to the maintainers.

> [!seealso]
> [The Flipbook Interface](./the-flipbook-interface.md): where the actions named above live
> [Story Format](../api/story-format.md) · [Storybook Format](../api/storybook-format.md)
