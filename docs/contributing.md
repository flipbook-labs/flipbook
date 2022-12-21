---
sidebar_position: 5
---

# Contributing

Thank you for your interest in contributing to this repository! This guide will help you get your environment setup so you can have the best possible development experience.

## Getting Started

You should be using [Visual Studio Code](https://code.visualstudio.com/) as your text editor, and have the following extensions installed:

- [Rojo](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo)
- [Selene](https://marketplace.visualstudio.com/items?itemName=Kampfkarren.selene-vscode)
- [StyLua](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua)
- [Luau LSP](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp)

Once the Rojo extension is installed a welcome screen will be displayed. Scroll down to the section for the Roblox Studio plugin and select "Manage it for me." Next time you open a place in Studio you will have the Rojo plugin ready to go.

Next install our toolchain manager, [Foreman](https://github.com/Roblox/foreman/). Foreman handles the installation of several of our other tools, like Rojo, Wally, Selene, and StyLua.

To make the tools that Foreman installs avialable on your system you will need to manually add it to your `PATH`.

- Windows
  - Add `C:\Users\You\.foreman\bin` to your `PATH`
  - Follow [this guide](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/) for how to do that
- MacOS
  - Open Terminal
  - Open the corresponding file for your terminal
    - Bash: `nano ~/.bash_profile`
    - ZSH: `nano ~/.zshenv`
  - Append `export PATH="$PATH:~/.foreman/bin` to the end of the file

## Development

With the above requirements satisfied, run the following commands from your clone of this repository to start developing:

```sh
# Install Rojo, Wally, Selene, StyLua, and others
foreman install

# Install dependencies
wally install
```

Next use Rojo to build the plugin:

```sh
# Windows
rojo build -o $LOCALAPPDATA/Roblox/Plugins/flipbook.rbxm

# MacOS
rojo build -o ~/Documents/Roblox/Plugins/flipbook.rbxm
```

Once built, open up a Baseplate to start interacting with the plugin.

You can also run `rojo build` with the `--watch` flag while developing so that the plugin gets rebuilt when changes are made. Once rebuilt, simply reload to a new Baseplate for the changes to take effect.

## Using flipbook to develop flipbook

flipbook is made up of Roact components, each of which has a story file. This means you can use flipbook itself for developing it.

Once you have flipbook built you can make the following changes to have the internal storybook shown in the sidebar:

1. In the Studio settings turn on "Plugin Debugging Enabled"
2. Edit `constants.lua` and set `IS_DEV_MODE = true`. Make sure not to commit this change.

Then load a new Baseplate and open the flipbook plugin to view the stories

## Testing

While developing, you should also be writing unit tests. Unit tests are written in `.spec.lua` files. You can see examples of this throughout the repository's codebase.

To run tests, simply start the experience in Studio. You will see in the output if tests are passing or failing.

If your code is not properly tested, maintainers will let you know and offer suggestions on how to improve your tests so you can get your pull request merged.
