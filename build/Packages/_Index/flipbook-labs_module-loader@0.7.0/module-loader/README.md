# ModuleLoader

[![CI](https://github.com/flipbook-labs/module-loader/actions/workflows/ci.yml/badge.svg)](https://github.com/flipbook-labs/module-loader/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-website-brightgreen)](https://flipbook-labs.github.io/module-loader)

Module loader class that bypasses Roblox's require cache.

This class aims to solve a common problem where code needs to be run in Studio, but once a change is made to an already required module the whole place must be reloaded for the cache to be reset. With this class, the cache is ignored when requiring a module so you are able to load a module, make changes, and load it again without reloading.

## Usage

```lua
local ModuleLoader = require(ReplicatedStorage.Packages.ModuleLoader)

local loader = ModuleLoader.new()
loader:require(ReplicatedStorage.ModuleScript)
```

## Installation

Installing the package is quick and easy whether you use a package manager like [Wally](https://github.com/UpliftGames/wally) or work directly in Studio.

### Wally (Recommended)

Add the following to your `wally.toml` and run `wally install` to download the package.

```toml
[dependencies]
ModuleLoader = "flipbook-labs/module-loader@0.6.1"
```

Make sure the resulting `Packages` folder is synced into your experience using a tool like [Rojo](https://github.com/rojo-rbx/rojo/).

### Roblox Studio

* Download a copy of the rbxm from the [releases page](https://github.com/flipbook-labs/module-loader/releases/latest) under the Assets section.
* Drag and drop the file into Roblox Studio to add it to your experience.
## Documentation

You can find the documentation [here](https://flipbook-labs.github.io/module-loader).

## Credits

Parts of this class were taken verbatim from [OrbitalOwen/roblox-testservice-watcher](https://github.com/OrbitalOwen/roblox-testservice-watcher), and other parts were rewritten to allow the module loading code to be abstracted into a new package.

## Contributing

See the [contributing guide](https://flipbook-labs.github.io/module-loader/docs/contributing).

## License

[MIT License](LICENSE)