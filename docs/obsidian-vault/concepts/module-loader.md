---
aliases: [ModuleLoader, story sandboxing]
linter-yaml-title-alias: ModuleLoader
---

# ModuleLoader

Flipbook's story sandboxing is powered by [ModuleLoader](https://github.com/flipbook-labs/module-loader), a package we maintain for loading [Story](./story.md) and [Storybook](./storybook.md) modules. It loads each module fresh, bypassing Roblox's `require` cache, so editing a Story hot-reloads its preview without restarting the plugin.

> [!seealso]
> [Module Loader](../engineering/module-loader.md): Maintainer notes on the loader's design and the in-progress refactor
