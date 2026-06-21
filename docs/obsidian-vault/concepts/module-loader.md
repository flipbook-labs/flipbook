---
aliases: [ModuleLoader, story sandboxing]
linter-yaml-title-alias: ModuleLoader
---

# ModuleLoader

Flipbook's story sandboxing is powered by [ModuleLoader](https://github.com/flipbook-labs/module-loader), a package we maintain for loading [[story]] and [[storybook]] modules. It loads each module fresh, bypassing Roblox's `require` cache, so editing a Story hot-reloads its preview without restarting the plugin.

> [!seealso]
> [[engineering/module-loader|Module Loader]] — Maintainer notes on the loader's design and the in-progress refactor
