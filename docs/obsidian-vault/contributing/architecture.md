---
aliases: [Architecture]
linter-yaml-title-alias: Architecture
---

# Architecture

A map of the codebase and the build pipeline that turns it into a distributable Roblox plugin.

## Source layout

```
flipbook/
  src/
    init.server.luau       # Plugin entry point
  .lute/                   # Lute task scripts (build, test, lint, …)
    build.luau
    test.luau
    analyze.luau
    tasks/                 # Sub-tasks imported by top-level scripts
  .darklua.json            # darklua transformation config
  default.project.json     # Rojo project (points to build/dev/roblox)
  dev.project.json         # Rojo project for dev builds
  tests.project.json       # Rojo project for running tests
  loom.config.luau         # Version source (kept in sync by changewrite)
  rokit.toml               # Toolchain: darklua, rojo, lute, luau-lsp, …
```

Source code lives in `src/` and is written in Luau with **string requires** (`require("@scripts/lib/foo")`, `require("@repo/project")`, `require("@luaupkg/...")`), the same syntax as Lute scripts. These require strings are not valid inside Roblox and must be rewritten before packaging.

## Build pipeline

```
src/ (Luau, string requires)
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

**Why darklua?** Roblox requires property access (`require(script.Parent.Foo)`) while string requires are far more ergonomic for a large codebase. darklua bridges the gap by rewriting requires at compile time, letting source code and Lute scripts share the same import syntax.

**Channels**: `dev` keeps test files, Storybooks, and Stories in the build (useful for working on Flipbook itself). `prod` strips them. Pass `--channel dev` or `--channel prod` to `lute run build`.

**Watch mode**: `lute run build --watch` reruns darklua + Rojo on file changes and reloads the plugin in Studio (requires "Plugin Debugging Enabled" in Studio settings).

## Testing

Tests are in `.spec.luau` files colocated with source modules, using jsdotlua's [Jest](https://jsdotlua.github.io/jest-lua/) port.

To run them locally:

1. Copy `.env.template` to `.env` and set `ROBLOX_API_KEY` to a valid Open Cloud key (ask a maintainer).
2. Run:

```sh
lute run test
```

Tests run **inside Roblox** via Lune's Roblox environment. The test entry point (`tests.project.json`) bootstraps the Jest runner from a place file. This means tests can touch real Roblox APIs.

> [!TIP]
> The CI `analyze` job runs luau-lsp type checking (`lute run analyze`) and selene linting (`lute run lint`) on every PR. Run them locally before opening a PR to catch type errors early.

## CI

| Job             | When                    | What it does                                             |
| --------------- | ----------------------- | -------------------------------------------------------- |
| `build-plugin`  | every PR / push to main | Builds `dev` + `prod` plugin `.rbxm`, attests provenance |
| `build-package` | every PR / push to main | Builds the `flipbook-core` package for Rotriever         |
| `analyze`       | every PR / push to main | Luau type check + selene lint                            |

Tests do not run in CI (they require a secret API key and run against Roblox infra). Type checking catches most logic errors instead.

The release workflow (`release.yml`) triggers on GitHub release events to build and publish the plugin to the Creator Store.

> [!seealso]
> [[contributing/onboarding|Onboarding]]: First-time setup and build commands
> [[contributing/creating-releases|Creating Releases]]: Version bumping and publishing
> [[engineering/module-loader|Module Loader]]: How require bypassing works at runtime
