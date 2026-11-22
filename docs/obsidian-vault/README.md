---
aliases: [Flipbook, README]
linter-yaml-title-alias: Flipbook
---

# Flipbook

![Flipbook icon](./assets/flipbook-icon.png)

Flipbook is a storybook plugin that previews UI components in a sandboxed environment. With it you can isolate distinct parts of your game's UI to hammer out edge cases and complex states without having to run through the whole UI.

With native support for popular UI libraries like [React](./usage/frameworks/react.md), [Fusion](./usage/frameworks/fusion.md), and [Roact](./usage/frameworks/roact.md), no matter how you create UI you can write a story for it in Flipbook.

[![Get it on Creator Store](assets/link-creator-store.svg)](https://create.roblox.com/store/asset/8517129161/flipbook) [![Read the documentation](assets/link-docs.svg)](https://flipbook-labs.github.io/flipbook) [![Join the discussion on Discord](assets/link-discord.svg)](https://discord.com/channels/385151591524597761/1063913358740443336/1063913358740443336)

---

## Usage

- [Getting Started](./usage/getting-started.md): Install Flipbook and write your first story
- [Writing Stories](./usage/writing-stories.md): Storybooks, Stories, and file organization
- [Controls](./usage/controls.md): On-the-fly UI configuration via story controls
- [Typechecking](./usage/typechecking.md): Type-safe stories with Storyteller

## API Reference

- [Storybook Format](./api/storybook-format.md): Storybook module properties
- [Story Format](./api/story-format.md): Story module properties
- [StoryProps](./api/story-props.md): Props passed to story functions
- [Concepts](./concepts/index.md): Story, Storybook, ModuleLoader, Storyteller

## Contributing

- [Onboarding](./contributing/onboarding.md): Dev environment setup, building, and testing
- [Creating Releases](./contributing/creating-releases.md): Version bumping and publishing

## Engineering

- [Engineering](./engineering/index.md): Technical specs, proposals, and internal working notes

## Product

- [Product](./product/index.md): Northstars, roadmap, and feature wishlist

---

## Inspirations

Flipbook takes inspiration from several different sources:

1. [Storybook.js](https://storybook.js.org/)
2. [Hoarcekat](https://github.com/Kampfkarren/hoarcekat)
3. [UI Labs](https://ui-labs.luau.page/)
4. Developer Storybook (Roblox's internal storybook plugin)

## License

Flipbook is licensed under the MIT license. View the license text at [LICENSE](https://github.com/flipbook-labs/flipbook/blob/main/LICENSE).
