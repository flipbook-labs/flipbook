---
name: use-studio-mcp-for-flipbook
description: Verify Flipbook inside an open Roblox Studio session using Studio MCP and FlipbookAgentGateway. Use when testing the Flipbook plugin, embedded Flipbook, gateway actions, execute_luau, CoreGui.FlipbookAgentGateway, screenshots, visual QA, story interaction, or Studio-side behavior.
---

# Use StudioMCP For Flipbook

## When To Use

Use this skill when validating Flipbook in Roblox Studio. Flipbook's agent-facing API is `FlipbookAgentGateway`; prefer gateway actions over navigating the UI by hand.

## Studio MCP Access

The repo registers Studio MCP in `.mcp.json` as `Roblox_Studio`. If your agent host exposes that server, call those MCP tools directly.

If direct MCP calls are not available, use Lute for any fallback script or REPL probe. Read the command from `.mcp.json` instead of hardcoding it. Keep transport details inside the helper and invoke tools at the level of `execute_luau`, `screen_capture`, `start_stop_play`, etc. Do not add Python JSON-RPC clients to this skill.

Official Studio MCP docs: https://create.roblox.com/docs/studio/mcp

Useful Studio MCP tools for Flipbook:

- `list_roblox_studios` - list connected Studio instances.
- `set_active_studio` - select the target Studio instance.
- `get_studio_state` - confirm Edit/Client/Server data models and play state.
- `execute_luau` - run Luau in Studio. Use `datamodel_type = "Edit"` for plugin and gateway checks.
- `start_stop_play` - start or stop play mode for embedded visual checks.
- `screen_capture` - capture the viewport. It does not capture plugin dock widgets.

If Studio MCP reports no active instance, first call `list_roblox_studios` and `set_active_studio`. If that still fails, `search_game_tree` against `Workspace` or `PluginDebugService` can be used as a fallback probe before retrying.

If a tool returns `Not connected to the WS host`, stop and ask the user to make sure Studio MCP is enabled in the open Studio session. That is a connection failure, not an active-instance selection failure, so `search_game_tree` retries will not fix it.

## Two Validation Modes

### Programmatic Checks

Use Edit-mode `execute_luau` and `FlipbookAgentGateway` for fast checks. This is the default path for opening the widget, listing stories, opening a story, setting controls, changing screens, changing theme, and invoking story actions.

### Visual And Interactive Checks

`screen_capture` captures the viewport, not plugin GUIs, so it cannot see Flipbook's dock widget. For visual verification, embed Flipbook into the experience with `embedFlipbook`, then start play mode. The embedded runtime mounts as a normal `ScreenGui` in the viewport, so screenshots and real input events work.

Prefer gateway actions for anything they cover. Use `user_mouse_input` / `user_keyboard_input` only for a story's own interactions, such as clicking a story button, or as an escape hatch for Flipbook's own UI. If you need the escape hatch for Flipbook UI, tell the user and consider whether a new gateway action would be a better fit.

`embedFlipbook` mutates the place by cloning the Flipbook runtime into `ReplicatedStorage` by default. Only embed when the user wants visual or interactive verification. A second call without `overwrite = true` should fail with the existing runtime path.

## Flipbook Gateway Validation Order

Build the plugin first when local code changed.

```bash
lute run build plugin --channel dev --clean
```

Then use `execute_luau` in the Edit data model. This inline `gateway:Invoke` shape should be the first thing an agent reaches for:

```lua
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local gateway = CoreGui:FindFirstChild("FlipbookAgentGateway")
assert(gateway ~= nil, "missing FlipbookAgentGateway")

local result = {}
result.widget = gateway:Invoke({ method = "call", action = "openWidget" })
result.manifest = gateway:Invoke({ method = "list" })
result.storybooks = gateway:Invoke({ method = "call", action = "listStorybooks" })
return HttpService:JSONEncode(result)
```

Gateway `method = "call"` responses are wrapped. Successful calls usually return `{ ok = true, result = ... }`; failed calls return `{ ok = false, error = ... }`. When chaining calls, read from `response.result` instead of assuming the action payload is the top-level table.

Recommended programmatic sequence:

1. `openWidget`
2. `list` manifest request
3. `refreshStorybooks` or `listStorybooks`
4. `listStories`
5. `openStory`
6. Poll readiness before `setControls` or mounted-story actions
7. `setControls` if the story has controls
8. `navigate`, `getScreen`, `setTheme`, `viewportPreview`, `viewExplorer`, `zoomIn`, or `zoomOut` as needed

`setControls` requires the story view to be mounted. Do not use a fixed sleep. For stories with controls, poll for the newly-opened story and an expected control key before calling it. For viewport-preview checks, call `viewportPreview` and then poll `getStoryActions.isMountedInViewport`.

```lua
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local gateway = CoreGui:FindFirstChild("FlipbookAgentGateway")
assert(gateway ~= nil, "missing FlipbookAgentGateway")

local storyPath = "ReplicatedStorage.Example.Stories.Button.story"
local expectedControlKey = "label"

gateway:Invoke({
	method = "call",
	action = "openStory",
	params = {
		story = storyPath,
	},
})

local ready = false
for _ = 1, 60 do
	local currentStory = gateway:Invoke({ method = "call", action = "getCurrentStory" })
	local controls = gateway:Invoke({ method = "call", action = "getControls" })

	if
		currentStory.ok
		and currentStory.result ~= nil
		and currentStory.result.path == storyPath
		and controls.ok
		and controls.result ~= nil
		and controls.result.controls ~= nil
		and controls.result.controls[expectedControlKey] ~= nil
	then
		ready = true
		break
	end

	task.wait()
end

assert(ready, "story did not become ready for controls")

local result = gateway:Invoke({
	method = "call",
	action = "setControls",
	params = {
		controls = {
			label = "Clicked",
		},
	},
})

return HttpService:JSONEncode(result)
```

## Visual Flow

```lua
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local gateway = CoreGui:FindFirstChild("FlipbookAgentGateway")
assert(gateway ~= nil, "missing FlipbookAgentGateway")

local result = gateway:Invoke({
	method = "call",
	action = "embedFlipbook",
	params = {
		parent = "ReplicatedStorage",
		overwrite = false,
	},
})

return HttpService:JSONEncode(result)
```

After embedding, use `start_stop_play { is_start = true }`, wait for the client data model to be available, and take `screen_capture`. If the screenshot is blank or not the Studio viewport, ask the user to bring Studio to the foreground before retrying.

Stop play mode with `start_stop_play { is_start = false }` when done unless the user asks to leave the experience running.

## Gateway Action Discovery

Do not maintain a static action catalog in this skill. Query the gateway manifest with `method = "list"` and treat that response as the source of truth for action names, descriptions, and input schemas.

```lua
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local gateway = CoreGui:FindFirstChild("FlipbookAgentGateway")
assert(gateway ~= nil, "missing FlipbookAgentGateway")

return HttpService:JSONEncode(gateway:Invoke({ method = "list" }))
```

If an agent cannot tell how to call an action from the manifest, update the action's AgentGateway metadata in Flipbook instead of adding a parallel explanation here. The skill should explain the workflow; the gateway should describe the callable surface.

## Notes

- Programmatic checks should stay on gateway actions. Manual UI input is slower and more brittle.
- `screen_capture` is for embedded visual checks, not plugin widgets.
- `search_game_tree` is a fallback for Studio MCP selection issues, not the normal Flipbook navigation path.
