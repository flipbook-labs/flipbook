---
sidebar_position: 5
---

# Contributing

Thank you for your interest in contributing to this repository! This guide will help you get your environment setup so you can have the best possible development experience.

## Onboarding

We use [Visual Studio Code](https://code.visualstudio.com/) to work on this project, so you'll get the best mileage from using it too. We also have several [recommended extensions](https://github.com/flipbook-labs/flipbook/blob/main/.vscode/extensions.json) that should be installed.

You will also need [Just](https://github.com/casey/just) for running commands, and [Foreman](https://github.com/Roblox/foreman/)
for installing pinned tool versions.

With the above requirements satisfied, run the following commands from your clone of the repo to start developing:

```sh
# Install tools and packages that the project depends on
just init

# Build the plugin to Studio
just build
```

:::tip
When using VSCode, you can press `Ctrl+Shift+B` on Windows or `Cmd+Shift+B` on MacOS to execute the included build task which will build the flipbook plugin for your OS.
:::

Once built, open up a Baseplate to start interacting with the plugin.

## Using flipbook to develop flipbook

flipbook is made up of Roact components, each of which has a story file. This means you can use flipbook itself for developing it.

Once you have flipbook built, navigate to the Studio settings and turn on "Plugin Debugging Enabled."

![Screenshot of the Studio settings showing the Plugin Debugging Enabled option](/img/plugin-debugging-enabled.png)

Then load a new Baseplate and open the flipbook plugin. Its storybook should now appear in the sidebar.

## Testing

While developing, you should also be writing unit tests. Unit tests are written in `.spec.luau` files. You can see examples of this throughout the repository's codebase.

To run tests, simply start the experience in Studio. You will see in the output if tests are passing or failing.

If your code is not properly tested, maintainers will let you know and offer suggestions on how to improve your tests so you can get your pull request merged.
