---
name: architecture
description: "Flipbook's non-obvious design contracts: the Pluginlike abstraction and embedding, the Flipbook to Storyteller to ModuleLoader layering, why state lives in Charm stores, how ModuleLoader reloads behave, differences between the plugin and embedded contexts, and the community-first policy for the internal build, telemetry, and claims about competing tools. Use when: changing embedding or plugin bootstrap code, touching story loading or reload behavior, adding a store, adding telemetry, working on the rotriever or internal build, or writing a claim about UI Labs or another tool."
---

# Flipbook Architecture

This skill holds the contracts that the code does not make obvious. For repo layout, tooling, and the Charm frozen-flag workaround, read the repo's `AGENTS.md`. For story formats, control types, and framework return shapes, read the docs site under `docs/docs/creating-stories/` and `docs/docs/frameworks/` in the Flipbook repo, and Storyteller's `src/types.luau`.

## Pluginlike and embedding

Flipbook runs in two places: as a Studio plugin, and as a client-side app embedded in an experience. Both mount through `createFlipbookApp`, which takes a `Pluginlike` instead of the real `plugin` object. `Pluginlike` is declared in `workspace/flipbook-core/src/Common/types.luau` and has four methods: `GetMouse`, `GetSetting`, `SetSetting`, and `OpenScript`.

The type is the decoupling point. Code in `flipbook-core` must not reach for any other member of `plugin`, because the embedded runtime has no plugin to call. When no plugin is passed, `createFlipbookApp` substitutes a stub (`defaultPlugin`) whose settings reads return nil and whose `OpenScript` does nothing. If you need a new plugin capability, add it to `Pluginlike`, give the stub a safe default, and decide what the embedded context does without it.

The entry points differ by wrapper:

- `createFlipbookPlugin` passes the real plugin, a dock widget, and `AppMode.PluginWidget`. It mounts lazily when the widget becomes visible.
- `createEmbeddedFlipbookApp` passes a `ScreenGui` and `AppMode.EmbeddedClient`, and mounts immediately.

Branch on `AppMode` for context-specific UI. The topbar already does this: the viewport control only shows in the plugin, and the "Embed into Experience" action is hidden once embedded.

Keep the starter scripts under `src/` thin. Each one guards its context, then delegates to `flipbook-core`. The embedded scripts return early when they sit under `PluginDebugService`, so a plugin-debug session does not start a second app. The embedded server script disables `Players.CharacterAutoLoads` so characters do not spawn behind the UI. Launch data is read on the server from `Player:GetJoinData()` and handed to the client through a `RemoteFunction`, because the client cannot read join data itself.

`embedFlipbookRuntime` clones the running Flipbook build and tags the clone with `FLIPBOOK_RUNTIME_TAG`. It destroys any previously tagged runtime first, so an experience holds one embedded Flipbook. Embedding clones whichever build is running, which means a dev build embeds a dev build.

### Embedded limits

Embedded Flipbook runs as an ordinary client script. It has no plugin APIs, and settings come through the `Pluginlike` stub rather than Studio's plugin settings. It has no plugin HTTP access either. `HttpService` requests are not available to client scripts, so telemetry and feedback sent through `requestAsync` fail from the embedded client. `requestAsync` catches that and logs a warning, so the failure is silent for the user. Do not add a feature that needs HTTP in embedded mode without a server-side path for it.

## Layering

The dependency chain is Flipbook, then Storyteller, then ModuleLoader. Each layer owns one concern.

- ModuleLoader loads a module with a fresh cache. It knows nothing about stories.
- Storyteller discovers, loads, migrates, and renders stories. It knows nothing about Flipbook's UI.
- Flipbook is the interface on top. It calls Storyteller's functions and does not load or require story modules itself.

UI Labs schemas are migrated in Storyteller and never parsed in Flipbook. `loadStoryModule` runs the controls through `migrateControlsSchema`, and the per-source migrations live under `src/controls/migrations/` in Storyteller. Flipbook only ever sees the Storyteller schema. To support another control format, add a migration there, using the README in that folder.

## Why stores use Charm

State is held in Charm signals and computed values, then read in React through the signal hooks. Charm fits because derived state, such as merged control values or a tree node's descendants, stays correct as its inputs change, and a component subscribes only to the signal it reads. In the controls panel, changing one control does not re-render its siblings. Storyteller's own stores use Charm too, so Flipbook and Storyteller share one reactive model.

Keep app-level state in a store and expose it through a React context. Reserve `useState` for local component state, such as whether a dialog is open. When a loop or cleanup reads state that should not become a dependency, use `Charm.untracked`. `createTreeNodeStore` does this when it walks descendants.

## Reload behavior

Storyteller loads each story through a `ModuleLoader`, which re-evaluates the module instead of using Roblox's require cache. Three consequences are easy to miss.

- A story file's module-scope state resets on every reload, because the module runs again. Do not rely on module-scope values to carry state across reloads.
- Storybook `packages` are pre-cached into the loader. Libraries like React keep one identity across reloads, which is what lets elements from a story match the renderer's copy. State held inside such a shared package persists.
- Inside a loaded module, `_G` is a proxy. `ModuleLoader.isSandboxed()` tells code whether it runs under a loader or under native `require`.

Flipbook's own modules are not loaded this way. Only user story code goes through the loader.

## Community-first policy

The internal build is a mirror of the community build, not a privileged tier. It is built with `lute run build --target rotriever` and ships the same code. Apply these rules in review.

- The internal build must not gain a feature the community build cannot have. A feature that depends on an internal-only API needs a community-compatible fallback, or it does not ship.
- The internal build's red lines: no `GetService` calls for internal-only services, no UI or behavior keyed on detecting an internal universe, and no telemetry events the community build does not also send and disclose.
- Use `tryGetService` for services that might be absent in a context. Do not work around a missing service with internal-only code.
- To check a change, confirm it also works in a build from `lute run build plugin --channel prod`.

### Telemetry

Every in-plugin event goes through the telemetry client's `capture`, which sends nothing unless consent is `Granted`. Keep that single gate. The client lives in `workspace/flipbook-telemetry`, and `createTelemetry` connects it to plugin settings and the backend. Consent starts `Unknown`. The first-run dialog (`TelemetryConsentDialog`) and the Settings row (`TelemetrySettingRow`) change it. The embedded client never collects. Events carry a random ID that the client creates when someone grants consent and deletes when they revoke it, never a user ID. `types.luau` in `flipbook-telemetry` mirrors the backend's event enum, so the backend must accept an event before the plugin sends it. Do not add event properties that hold user IDs, names, file paths, or place or universe IDs.

Release-pipeline health is reported separately from Lute through `.lute/posthog.luau`. That path never runs inside the plugin.

### Claims about other tools

Mark any claim about UI Labs or another storybook tool as unverified unless you checked it against that tool, or a test or story in this repo proves it. This covers usage, feature depth, and responsiveness. A statement like "Flipbook supports UI Labs controls" needs a story that renders UI Labs control types correctly. Do not describe a feature as shipped unless its code is on `main`. Describe the embedded runtime as available to community users, since it needs no internal API.

## Re-verify

**Re-verify these claims when this skill next loads.** Run these from the repo root. A command that fails or prints nothing means the skill needs updating:

```sh
git grep -n -E "createFlipbookPlugin|createEmbeddedFlipbookApp" -- workspace/flipbook-core/src
git grep -n "type Pluginlike" -- workspace/flipbook-core/src
git grep -n "FLIPBOOK_RUNTIME_TAG" -- workspace
git grep -n "ConsentState.Granted" -- workspace/flipbook-telemetry/src/createTelemetryClient.luau
git grep -n -E "TelemetryConsentDialog|TelemetrySettingRow" -- workspace/flipbook-core/src
```
