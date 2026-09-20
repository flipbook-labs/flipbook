---
aliases: [Architecture]
linter-yaml-title-alias: Architecture
---

# Architecture

A map of the codebase and the build pipeline that turns it into a distributable Roblox plugin.

## Source Layout

```
flipbook/
  src/                     # Thin plugin and embedded-runtime bootstraps
  workspace/
    flipbook-core/         # React app, story browser, settings, and telemetry
    flipbook-agents/       # AgentGateway actions, controller, and protocol types
    test-runner/           # Jest runner
    example/               # Dogfood Stories and components
    code-samples/          # Source-backed documentation examples
    flipbook-next/         # Experimental next-generation package
    template/              # Workspace-member scaffold
  docs/
    obsidian-vault/        # Documentation source
    site/                  # Docusaurus renderer
    code-samples/          # Shared code-sample extraction tools
  .lute/                   # Build, test, lint, analysis, and install tasks
  project.luau             # Shared repository paths and build configuration
  sourcemap.project.json   # Rojo source map input
  loom.config.luau         # Lute dependencies and AgentSkills pin
  wally.toml               # Roblox runtime dependencies and version mirror
  rokit.toml               # Pinned command-line tools
```

Most application code lives in `workspace/flipbook-core/src/`. The root `src/` directory contains the bootstraps that create the plugin or start the embedded runtime. Source uses string requires such as `require("@workspace/flipbook-core/src")` and `require("@repo/project")`. Darklua rewrites them before Roblox packages the result.

## Build pipeline

```
src/ + workspace/ (Luau, string requires)
  │
  ▼
darklua
  │  convert_require: rewrites string requires → property access
  │  inject_global_value: injects BUILD_VERSION, BUILD_CHANNEL, etc. from .env
  │  remove_unused_if_branch / remove_empty_do / …: dead-code stripping
  │
  ▼
build/<channel>/<target>/   (Luau, property-access requires)
  │
  ▼
Rojo
  │  packages the transformed source into a .rbxm or syncs to Studio
  │
  ▼
Flipbook.rbxm  /  Studio plugins folder
```

The whole pipeline is driven by `lute run build`. Lute is a Luau task runner; build scripts live in `.lute/`.

**Why darklua?** Roblox requires property access such as `require(script.Parent.Foo)`. Darklua rewrites the source imports at compile time so application code and Lute scripts can use the same aliases.

**Channels**: `dev` keeps test files, Storybooks, and Stories in the build. `beta` and `prod` prune development-only workspace members and files. Pass the channel to `lute run build plugin --channel <channel>`.

**Targets**: the default `roblox` target builds the plugin. The `rotriever` target builds the `flipbook-core` package used by internal consumers. `lute run build storybook` produces the preview place consumed by the Storybook deployment workflow.

**Watch mode**: `lute run build plugin --channel dev --watch` recompiles changed source and reloads the plugin in Studio. Studio must have Plugin Debugging Enabled.

## Agent Runtime

`workspace/flipbook-agents` provides the AgentGateway boundary separately from `flipbook-core`. Its controller receives application and mounted-Story adapters, then exposes actions for opening the widget, embedding Flipbook, listing Storybooks and Stories, opening a Story, reading the current Story, and getting or setting Controls.

The controller only exposes operations backed by the currently registered adapters. For example, `setControls` requires the selected Story view to be mounted. Keeping this layer separate lets plugin and embedded surfaces share the protocol without putting Studio objects into the action definitions.

## Testing

Tests are in `.spec.luau` files colocated with source modules, using jsdotlua's [Jest](https://jsdotlua.github.io/jest-lua/) port.

Run the local repository checks before opening a pull request:

```sh
lute run check
```

This command validates the change entry, runs formatting and static analysis, and produces a clean development plugin build. Cloud tests require an Open Cloud key and a test universe that you control:

```sh
lute run test
```

The strict workflow builds the test place from pull-request code on a secretless runner. A protected runner then executes that artifact against Roblox after environment approval.

> [!TIP]
> The CI `analyze` job runs luau-lsp type checking (`lute run analyze`) and selene linting (`lute run lint`) on every PR. Run them locally before opening a PR to catch type errors early.

## CI

| Job             | When                    | What it does                                                           |
| --------------- | ----------------------- | ---------------------------------------------------------------------- |
| `changelog`     | every PR                | Requires a valid Changewrite entry                                     |
| `build-plugin`  | every PR / push to main | Builds and uploads `dev`, `beta`, and `prod` plugin models             |
| `build-package` | every PR / push to main | Builds `flipbook-core` for Rotriever in all three channels             |
| `analyze`       | every PR / push to main | Runs `lute run check`, including lint, analysis, and a clean dev build |
| `strict`        | protected workflow      | Runs Roblox tests and deploys the smoketest plugin from built inputs   |

The release workflow builds `Flipbook.rbxm` and lets Changewrite open or update the next publish pull request. Publishing that generated release triggers the Creator Store deployment. Pushes to `main` also publish the beta build.

> [!seealso]
> [[contributing/onboarding|Onboarding]]: First-time setup and build commands
> [[contributing/creating-releases|Creating Releases]]: Version bumping and publishing
> [[engineering/module-loader|Module Loader]]: How require bypassing works at runtime
