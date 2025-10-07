
# Storyteller

[![CI](https://github.com/flipbook-labs/storyteller/actions/workflows/ci.yml/badge.svg)](https://github.com/flipbook-labs/storyteller/actions/workflows/ci.yml)

Storyteller is a package for the discovery and rendering of UI stories and powers our storybook plugin [Flipbook](https://github.com/flipbook-labs/flipbook).

The API for this package focuses around...
1. Validation for the Story format and Storybook format
2. Discvoery of valid ModuleScripts with `.story` and `.storybook` extensions
3. Loading of Stories and Storybooks into a sandbox with cacheless module requiring
4. Rendering stories into a container with lifecycle callbacks for updating and unmounting

There also exist React hooks for ease of integration into storybook apps.

## Features

* Discover Storybooks and their Story files
* Render stories written in React, Roact, Fusion, and any generic Roblox Gui.

## Installation

### Wally

```toml
[dependencies]
Storyteller = "flipbook-labs/storyteller@x.x.x"
```

### Roblox Model

Download a copy of the rbxm from the [latest release](https://github.com/flipbook-labs/storyteller/releases/latest) under the Assets section, then drag and drop the file into Roblox Studio to add it to your experience.

## Resources

API documentation is available on [the official documentation website](https://flipbook-labs.github.io/storyteller).

## Contributing

Contributions welcome! Proper steps on how to get started will come later but feel free to poke around in the meantime.

## License

The contents of this repository are available under the MIT License. For full license text, see [LICENSE](LICENSE).
