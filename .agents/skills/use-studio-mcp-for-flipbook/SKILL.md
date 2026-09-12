---
name: use-studio-mcp-for-flipbook
description: "Build and validate Flipbook through Studio MCP and FlipbookAgentGateway. Use when driving a local Flipbook build, changing gateway actions, or verifying Stories through semantic actions, embedded Play-mode input, and screenshots."
type: process
---

# Use Studio MCP for Flipbook

Build Flipbook, open the generated Storybook experience in Studio, use the gateway for semantic checks, and embed Flipbook for Play-mode interaction and screenshots. Keep behavior-specific fixtures and assertions in a reference beside this skill.

## When not to use

Use `run-flipbook-checks` for headless checks. Use `test-dependencies-in-flipbook` before this workflow when the task overlays Storyteller or ModuleLoader.

## Build and connect

```bash
lute run build plugin --channel dev --clean
lute run build storybook --channel dev --clean
```

Open the generated Storybook experience in a new Studio instance. The repository registers Studio MCP as `Roblox_Studio` in `.mcp.json`. Select the new instance with `list_roblox_studios` and `set_active_studio`, then use the Edit data model for gateway calls.

If Studio MCP reports `Not connected to the WS host`, stop and ask the user to enable Studio MCP in the open Studio session. Selecting the instance again does not repair that connection.

## Discover and call Flipbook

Flipbook publishes `CoreGui.FlipbookAgentGateway`. Begin with its manifest:

```lua
local HttpService = game:GetService("HttpService")
local gateway = game:GetService("CoreGui"):FindFirstChild("FlipbookAgentGateway")
assert(gateway ~= nil, "missing FlipbookAgentGateway")

return HttpService:JSONEncode(gateway:Invoke({ method = "list" }))
```

Actions use `{ method = "call", action = "<name>", params = { ... } }`. Responses are `{ ok = true, result = ... }` or `{ ok = false, error = ... }`; always check `ok` and read successful payloads from `result`.

Use this sequence:

1. Call `openWidget`.
2. Call `embedFlipbook` before Play mode when visual evidence or virtual input is needed.
3. Poll `listStorybooks` until the target Storybook appears.
4. Call `listStories` with the returned Storybook path.
5. Call `openStory` with returned Story and Storybook paths.
6. Poll `getCurrentStory` until the path matches and `isMounted` is true.
7. Poll `getControls` until the expected control appears.
8. Call `setControls`, then confirm the values with `getControls`.

Do not use fixed sleeps. Discover paths from gateway results instead of hard-coding a DataModel layout.

## Embedded visual and input checks

Studio MCP viewport captures do not include plugin dock widgets. For visual evidence, or when a missing semantic action makes UI input necessary, follow the [embedded Play-mode workflow](references/embedded-play-mode.md). Prefer gateway actions in Edit mode; use virtual input against the embedded client as an escape hatch and add a focused action when the same interaction becomes routine.

## Provenance and maintenance

**Date stamped:** 2026-09-12. Verified against `workspace/flipbook-agents/src/actions.luau`, `.mcp.json`, and the current build task names.

**Re-verify these claims when this skill next loads:**

- Inspect the action names and schemas, including `embedFlipbook`, in `workspace/flipbook-agents/src/actions.luau`.
- Inspect the server command in `.mcp.json`.
- Run `lute run build plugin --channel dev --clean` and `lute run build storybook --channel dev --clean`.
