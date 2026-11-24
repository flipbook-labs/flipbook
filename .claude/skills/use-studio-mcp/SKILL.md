---
name: use-studio-mcp
description: "Drive a local Flipbook build through the Studio MCP and the FlipbookAgentGateway actions, including embedded Play-mode screenshots and input. Use when: verifying Stories in Studio, changing gateway actions, or capturing visual evidence of Flipbook UI."
---

# Use Studio MCP for Flipbook

Build Flipbook, open the generated Storybook experience in Studio, drive it through the gateway, and embed it for visual checks. For the protocol, polling, and connection errors, read the shared `agent-gateway/use-agent-gateway` skill.

## When not to use

Use [`dev-env`](../dev-env/SKILL.md) for headless checks, and for overlaying local Storyteller or ModuleLoader changes first.

## Build and connect

```bash
lute run build plugin --channel dev --clean
lute run build storybook --channel dev --clean
```

Open the generated Storybook experience in a new Studio instance. The repository registers Studio MCP as `Roblox_Studio` in `.mcp.json`. Find the new instance's id with `list_roblox_studios` and pass it as `studio_id` on every call, then use the Edit data model for gateway calls.

The plugin build writes to the Studio Plugins folder that every checkout shares, so another checkout's build can replace yours mid-session. Before trusting a result, check that the widget under `PluginGuiService` is named `Flipbook [<sha>]` with the commit you built.

If Studio MCP reports `Not connected to the WS host`, stop and ask the user to enable Studio MCP in the open Studio session. Selecting the instance again does not repair that connection.

## Drive Flipbook

Find the gateway named `FlipbookAgentGateway` and follow the protocol in the shared `agent-gateway/use-agent-gateway` skill. Flipbook only creates this gateway once its app adapter is wired in. If the gateway isn't in `CoreGui`, the build you're running doesn't have it, so use the [embedded Play-mode workflow](#visual-and-input-checks) for navigation as well as capture.

Call `list` first, then use this order:

1. Call `openWidget`.
2. Call `embedFlipbook` before Play mode if you need screenshots or virtual input.
3. Poll `listStorybooks` until the target Storybook appears.
4. Call `listStories` with that Storybook path.
5. Call `openStory` with the Story and Storybook paths.
6. Poll `getCurrentStory` until the path matches and `isMounted` is true.
7. Poll `getControls` until the expected control appears.
8. Call `setControls`, then confirm with `getControls`.

Take every path from gateway results.

## Visual and input checks

Studio MCP viewport captures do not include plugin dock widgets, so a capture in Edit mode never shows Flipbook. Embed it and playtest instead.

1. Call `embedFlipbook`. It returns the `path` it embedded into. The `parent` param defaults to `ReplicatedStorage`. With no gateway, embed the runtime as described in [Embedding without the gateway](#embedding-without-the-gateway).
2. Start Play mode with `start_stop_play`, then poll `get_studio_state` until the Client data model appears.
3. Find the embedded UI under `LocalPlayer.PlayerGui.Flipbook` in the Client data model and wait for the target Story or control to appear. A blank or loading capture is not evidence.
4. Capture with `screen_capture`.
5. If no gateway action covers an interaction, use `user_mouse_input` or `user_keyboard_input` against a Client instance path you discovered. If the same fallback keeps recurring, add a gateway action for it.
6. Check Client console output when the UI does not mount or react.
7. Stop Play mode when you finish.

Embedding changes the open place. Do not pass `overwrite = true`, which replaces an existing embedded runtime, and do not save the place without the user's permission.

## Embedding without the gateway

The embedded runtime is the dev build placed under `ReplicatedStorage.Flipbook`. Its starter scripts mount the UI when Play mode starts. Without the gateway, there are two ways to get the runtime into a place.

The first needs no one at the keyboard. Build a place from a Rojo project that maps `ReplicatedStorage.Flipbook` to `build/dev/roblox` and sets `"emitLegacyScripts": false`, then open that place in Studio. The root `default.project.json` has the right tree, but by default Rojo emits a legacy `LocalScript` and `Script`, and those never run from `ReplicatedStorage`. If a place already has legacy starter scripts, replace each one with a `Script` whose `RunContext` is `Client` or `Server`.

The second is Flipbook's **Embed into experience** dialog, which a person has to click. It copies the installed plugin, not your checkout. Confirm the widget's commit before embedding.

## Driving the embedded UI

These behaviors were observed with the built-in Studio MCP server. Re-check them when input stops landing.

- `user_mouse_input` coordinates are in GUI space, matching `AbsolutePosition`. `screen_capture` also includes the top-bar inset, so a point read off a screenshot lands lower than intended. Read the target's `AbsolutePosition` and `AbsoluteSize` from the Client data model, and click its center.
- `mouseButtonClick` does not activate Foundation buttons. Send `mouseButtonDown`, wait about 80 ms, then send `mouseButtonUp`.
- The first press after a long move sometimes only hovers. Read the state back after every press, and press once more if nothing changed.
- A fresh profile opens the telemetry consent dialog first. Close it with its close affordance. **Done** would submit the checked consent box.
- Play-mode captures show the embedded UI as rendered. If a capture comes back as a solid color, stop and report it rather than using it as evidence.

## Re-verify

**Re-verify these claims when this skill next loads.** Run these from the repo root. A command that fails or prints nothing means the skill needs updating:

```sh
git grep -n -E "listStorybooks|openStory|setControls|getCurrentStory" -- workspace/flipbook-agents/src
git grep -n embedFlipbook -- workspace/flipbook-agents/src
git grep -n FlipbookAgentGateway -- workspace
# The root project embeds the dev build under ReplicatedStorage.Flipbook.
grep -n '"Flipbook"' default.project.json
# The embedded client mounts a ScreenGui named Flipbook.
git grep -n 'screenGui.Name = "Flipbook"' -- src/EmbeddedClientStarterScript.client.luau
```

To check whether the app wires in the gateway yet, run `git grep -n createAgentGateway -- workspace/flipbook-core/src src`. No match means builds have no gateway, and the embedded workflow is the only path.
