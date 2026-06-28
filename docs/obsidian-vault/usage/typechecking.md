---
aliases: [Typechecking]
linter-yaml-title-alias: Typechecking
---

# Typechecking

Stories and Storybooks are plain ModuleScripts, so by default a mistake in their shape (a missing `story` function or a misspelled field) only surfaces when Flipbook loads them. [[concepts/storyteller|Storyteller]], the library behind Flipbook, exports types you can annotate with to catch those mistakes as you write instead.

Add Storyteller to your project (via Wally, or the released model from the [Storyteller repo](https://github.com/flipbook-labs/storyteller)), then annotate your modules.

Annotate a Storybook with `Storyteller.Storybook`:

```code-sample
workspace/code-samples/src/ReactStoryteller/React.storybook.luau
```

And a Story with `Storyteller.Story<T>`, where `T` is the type your `story` function returns:

```code-sample
workspace/code-samples/src/ReactStoryteller/ReactButton.story.luau
```

With these annotations in place, Luau analysis (for example luau-lsp in your editor) flags a malformed Storybook or Story before you ever open it in Flipbook: a missing `story`, a mistyped `storyRoots`, or a control whose shape doesn't match.

Storyteller also exports `Storyteller.StoryProps` for the object passed to your story function, and the control types (`Storyteller.StoryControlsSchema` and the individual `*Control` types) for annotating [[usage/controls|controls]].

> [!seealso]
> [[concepts/storyteller|Storyteller]] · [[api/story-format|Story Format]] · [[api/storybook-format|Storybook Format]]
