---
aliases: [Frameworks]
---

# Frameworks

Flipbook has native support for the popular Roblox UI libraries, so you can write
stories no matter how you build your UI.

- [[usage/frameworks/react|React]]
- [[usage/frameworks/fusion|Fusion]]
- [[usage/frameworks/roact|Roact]]

## Default and Storyteller Variants

Each framework page shows its Storybook and Story in two forms:

- **Default**: a plain table. The quickest way to write a Story.
- **Storyteller**: the same module annotated with types from [[concepts/storyteller|Storyteller]], the library that powers Flipbook. Annotating gives you static typechecking on your Storybooks and Stories (see [[usage/typechecking|Typechecking]]), and it's where the `create*Control` constructors for richer [[usage/controls|controls]] come from.

Reach for the Storyteller form when you want type safety or the control constructors; otherwise the Default form is all you need.

> [!note]
> Storyteller is the engine behind Flipbook, and Stories import it directly for now. A dedicated `Flipbook` package that exposes just what a Story needs is planned, and will become the recommended import.
