---
aliases: [Frameworks]
---

# Frameworks

Flipbook has native support for the popular Roblox UI libraries, so you can write
stories no matter how you build your UI.

- [React](./react.md)
- [Fusion](./fusion.md)
- [Roact](./roact.md)

## Default and Storyteller Variants

Each framework page shows its Storybook and Story in two forms:

- **Default**: a plain table. The quickest way to write a Story.
- **Storyteller**: the same module annotated with types from [Storyteller](../../concepts/storyteller.md), the library that powers Flipbook. Annotating gives you static typechecking on your Storybooks and Stories (see [Typechecking](../typechecking.md)), and it's where the `create*Control` constructors for richer [controls](../controls.md) come from.

Reach for the Storyteller form when you want type safety or the control constructors; otherwise the Default form is all you need.

> [!note]
> Storyteller is the engine behind Flipbook, and Stories import it directly for now. A dedicated `Flipbook` package that exposes just what a Story needs is [planned](../../engineering/proposals/create-flipbook-package.md), and will become the recommended import.
