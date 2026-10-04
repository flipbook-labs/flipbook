---
aliases: [Storyteller]
linter-yaml-title-alias: Storyteller
---

# Storyteller

Storyteller is the backbone library behind Flipbook's story discovery and rendering pipeline. It finds Storybook and Story modules, instantiates story functions, and tears them down when you navigate away. It lives in its own repository, [flipbook-labs/storyteller](https://github.com/flipbook-labs/storyteller), and Flipbook depends on it like any other package.

Most of the time Storyteller works behind the scenes, but you meet it directly in two places:

- **Control constructors.** Functions like `createSliderControl` and `createSelectControl` come from Storyteller, and you require it in a Story to declare [[usage/controls|Controls]] that need more than a starting value.
- **Types.** Storyteller exports `Storyteller.Story<T>`, `Storyteller.Storybook`, and the control types, so you can typecheck your Story modules as you write them. See [[usage/typechecking|Typechecking]].

Add Storyteller to your project through Wally, or grab the released model from its repository, whenever you want either of these.

> [!seealso]
> [[usage/controls|Controls]]: declaring controls with Storyteller's constructors
> [[usage/typechecking|Typechecking]]: type-safe Stories with Storyteller's exported types
> [[engineering/proposals/storyteller-api|Storyteller API]]: Proposed API surface for the library
