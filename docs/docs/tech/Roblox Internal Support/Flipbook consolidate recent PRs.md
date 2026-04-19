---
notion-id: 27695b79-12f8-8173-b10a-e20d571b49e0
aliases: [ModuleLoader]
linter-yaml-title-alias: ModuleLoader
---

# ModuleLoader

 https://github.com/flipbook-labs/module-loader/pull/24

Just one PR needed but need to get tests passing. Might want to forego adependency graph for now to scope down for a new release?

# Storyteller

 https://github.com/flipbook-labs/storyteller/pull/29

## Distinguish between Available and Unavailable Storybooks

## Storybooks Handle Their Own Module Loading

```javascript
src/e2e/e2e.spec.luau
src/findStoryModulesForStorybook.spec.luau
src/hooks/useStory.luau
```

# Flipbook

## Fix Control Rendering for Dropdowns

```javascript
src/Storybook/StoryView.luau
src/Storybook/StoryControls.luau
```

## Code Blocks for Story Errors

```javascript
src/Common/CodeBlock.luau
src/Storybook/StoryError.luau
wally.toml
```

## Unavailable Storybooks

```javascript
src/Common/CodeBlock.luau
src/Storybook/StorybookError.luau
src/Storybook/StorybookError.story.luau
src/Storybook/StorybookTreeView.luau
wally.toml

```

## Storybook Onboarding

```javascript
src/Storybook/OnboardingTemplate/
src/Storybook/createOnboardingStorybook.luau
```

# Plugin Loading

```javascript
src/Plugin/createFlipbookPlugin.luau
src/Plugin/createToggleButton.luau
src/Plugin/createWidget.luau
src/init.server.luau
```
