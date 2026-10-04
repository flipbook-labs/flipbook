---
aliases: [Contributing]
linter-yaml-title-alias: Contributing
---

# Onboarding

Thank you for your interest in contributing to Flipbook! This guide walks through setting up a development environment, validating changes, and opening a pull request.

> [!info]
> This guide covers development of the Flipbook plugin. See [[usage/getting-started|Getting Started]] to learn how to use Flipbook in your own project.

## Fork and Clone the Repository

Start by [forking Flipbook](https://github.com/flipbook-labs/flipbook/fork). Clone your fork, then add the main repository as an `upstream` remote:

```sh
git clone https://github.com/<your-account>/flipbook.git
cd flipbook
git remote add upstream https://github.com/flipbook-labs/flipbook.git
```

Create each contribution from the latest `main` branch:

```sh
git fetch upstream
git switch -c my-change upstream/main
```

## Set Up Your Environment

We use [Visual Studio Code](https://code.visualstudio.com/) to work on Flipbook. The repository includes [recommended extensions](https://github.com/flipbook-labs/flipbook/blob/main/.vscode/extensions.json).

Install [Rokit](https://github.com/rojo-rbx/rokit/), then run these commands from the repository root:

```sh
rokit install
lute run install
cp .env.template .env
```

The checked-in `.env.template` values are enough for builds, linting, and static analysis. Keep `.env` local and never commit credentials.

> [!tip]
> In Visual Studio Code, press `Ctrl+Shift+B` on Windows or `Cmd+Shift+B` on macOS to run the included plugin build task.

## Validate Your Change

Every pull request needs one change entry. Add a Markdown file under [`.changes/`](https://github.com/flipbook-labs/flipbook/blob/main/.changes/README.md) that describes the user-visible effect. Internal-only maintenance uses a patch entry.

Run the repository checks before opening or updating a pull request:

```sh
lute run check
```

This command verifies the branch has a change entry, sets up local type definitions, checks formatting and static analysis, and produces a development plugin build. It does not require an Open Cloud API key.

## Open a Pull Request

Push your branch to your fork, then open a pull request against `flipbook-labs/flipbook:main`.

GitHub runs fork code in jobs that have no repository secrets and only read access. Cloud tests and Storybook preview publishing consume the resulting build artifacts on separate protected runners. Those protected jobs may wait for a maintainer to review the contribution and approve them.

You do not need to request a Flipbook Labs Open Cloud key. If GitHub shows a first-time contributor approval banner or a protected job is waiting, no action is required from you.

## Building

Flipbook uses [darklua](https://github.com/seaofvoices/darklua) to compile Luau source code for Roblox and support string requires in both source code and Lute scripts.

### Build for Studio

The following command builds production Flipbook to your Roblox Studio plugins directory:

```sh
lute run build
```

Open a Baseplate in Studio to start interacting with the plugin.

Production builds prune development files such as unit tests, Storybooks, and Stories. Use the development channel to keep them:

```sh
lute run build --channel dev
```

Add `--watch` to rebuild automatically when files change.

### Build an Rbxm File

Pass `--output` to choose where Flipbook writes the model. For example, this command writes it to the repository root:

```sh
lute run build --output Flipbook.rbxm
```

## Run Cloud Tests Locally

Local cloud tests are optional. They require an Open Cloud API key and test universe that you control, with the corresponding values configured in your local `.env` file:

```sh
lute run test
```

Flipbook uses jsdotlua's [Jest](https://github.com/jsdotlua/jest-lua) fork for unit tests. Existing `.spec.luau` modules show the expected patterns.

## Using Flipbook to Develop Flipbook

Flipbook's React components have Story files, so you can develop the plugin through its own Storybook.

After building Flipbook, open Studio settings and turn on "Plugin Debugging Enabled."

![Screenshot of the Studio settings showing the Plugin Debugging Enabled option](../assets/plugin-debugging-enabled.png)

Load a new Baseplate and open Flipbook. Its Storybook appears in the sidebar.

## Documentation Code Samples

Docs pull real Luau straight from `workspace/code-samples/` using a `code-sample`
fenced block, so examples stay correct:

````md
```code-sample
workspace/code-samples/src/React/ReactButton.luau#L4-L13
```
````

The Docusaurus site expands these at build time. For them to render in the
Obsidian vault, `lute run install` builds a small reading-view plugin into the
vault. After your first install, open the vault in Obsidian and enable the
**Code Sample** plugin under Settings -> Community plugins. See
[[contributing/architecture|Architecture]] or the `docs/code-samples/README.md`
for how the marker, the shared extractor, and the two adapters fit together.

## Internal Documentation

For deeper context on architecture, product direction, and in-flight proposals:

**Technical:**

- [[contributing/architecture|Architecture]]: Codebase layout and build pipeline details
- [[engineering/index|Technical Index]]: Module Loader, Story Container, Controls, Embedding, and more

**Product:**

- [[product/index|Northstars]]: Product vision and goals
- [[product/2026-roadmap|2026 Roadmap]]: Current quarterly roadmap
- [[product/2025-flipbook-product-spec/index|2025 Product Spec]]: Audiences and feature goals

**Proposals:**

- [[engineering/proposals/story-renderer-spec|Story Renderer Spec]] _(In Progress)_
- [[engineering/proposals/storyteller-api|Storyteller API]] _(In Progress)_
- [[engineering/proposals/story-storybook-typechecking|Story and Storybook Typechecking]] _(In Progress)_
- [[engineering/proposals/documentation-stories|Documentation Stories]] _(Approved)_
- [[engineering/proposals/modular-story-format|Modular Story Format]]
- [[engineering/proposals/create-flipbook-package|Flipbook Package]]

**Ideas:**

- [[product/ideas/index|Ideas Index]]: Toolbar, Storybook Selection UX, Right-click Context Menu
