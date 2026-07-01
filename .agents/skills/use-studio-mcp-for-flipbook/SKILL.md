---
name: use-studio-mcp-for-flipbook
description: Work on Flipbook's Studio MCP and FlipbookAgentGateway integration from inside the Flipbook repo. Use when editing gateway actions, gateway instructions, .mcp.json, or validating a local Flipbook plugin build in Roblox Studio.
---

# Use StudioMCP For Flipbook

## When To Use

Use this skill when you are working in the Flipbook repo on the Studio MCP / `FlipbookAgentGateway` integration.

Do not use this skill as the long-form consumer guide for other repos. Agents in Foundation or other experiences should learn Flipbook runtime behavior from the gateway itself:

1. Find `CoreGui.FlipbookAgentGateway`.
2. Call `gateway:Invoke({ method = "call", action = "getInstructions" })`.
3. Call `gateway:Invoke({ method = "list" })` for available action names, descriptions, and input schemas.

If those responses do not give enough information, improve the gateway action metadata or `getInstructions` response in Flipbook instead of adding parallel documentation to this skill.

## Repo Responsibilities

- Keep `.mcp.json` as the source of truth for the local Studio MCP command.
- Keep shared agent guidance in the gateway, currently `getInstructions` in `workspace/flipbook-core/src/Agent/actions.luau`.
- Keep action-specific usage details in each action's `title`, `description`, and `inputSchema`.
- Keep this skill focused on local development, build, and verification steps that only make sense inside the Flipbook repo.

## Local Studio MCP Access

The repo registers Studio MCP in `.mcp.json` as `Roblox_Studio`. If the current agent host exposes that server, call those MCP tools directly.

If direct MCP calls are not available, use Lute for any fallback script or REPL probe. Read the command from `.mcp.json` instead of hardcoding it. Keep transport details inside the helper and invoke tools at the level of `execute_luau`, `screen_capture`, `start_stop_play`, etc. Do not add Python JSON-RPC clients to this skill.

Official Studio MCP docs: https://create.roblox.com/docs/studio/mcp

Useful Studio MCP tools while developing Flipbook:

- `list_roblox_studios` - list connected Studio instances.
- `set_active_studio` - select the target Studio instance.
- `get_studio_state` - confirm Edit/Client/Server data models and play state.
- `execute_luau` - run Luau in Studio. Use `datamodel_type = "Edit"` for plugin and gateway checks.
- `start_stop_play` - start or stop play mode for embedded visual checks.
- `screen_capture` - capture the viewport. It does not capture plugin dock widgets.

If Studio MCP reports no active instance, first call `list_roblox_studios` and `set_active_studio`. If that still fails, `search_game_tree` against `Workspace` or `PluginDebugService` can be used as a fallback probe before retrying.

If a tool returns `Not connected to the WS host`, stop and ask the user to make sure Studio MCP is enabled in the open Studio session. That is a connection failure, not an active-instance selection failure, so `search_game_tree` retries will not fix it.

## Local Validation

Build the plugin first when local code changed.

```bash
lute run build plugin --channel dev --clean
```

Then use `execute_luau` in the Edit data model. This probe verifies that the gateway exists, exposes shared instructions, exposes an action manifest, and can open the widget:

```lua
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local gateway = CoreGui:FindFirstChild("FlipbookAgentGateway")
assert(gateway ~= nil, "missing FlipbookAgentGateway")

local result = {}
result.instructions = gateway:Invoke({ method = "call", action = "getInstructions" })
result.widget = gateway:Invoke({ method = "call", action = "openWidget" })
result.manifest = gateway:Invoke({ method = "list" })
result.storybooks = gateway:Invoke({ method = "call", action = "listStorybooks" })
return HttpService:JSONEncode(result)
```

Gateway `method = "call"` responses are wrapped. Successful calls usually return `{ ok = true, result = ... }`; failed calls return `{ ok = false, error = ... }`. When writing probes or tests, read from `response.result` instead of assuming the action payload is the top-level table.

Recommended validation sequence after changing gateway code or instructions:

1. `getInstructions`
2. `list` manifest request
3. `openWidget`
4. `refreshStorybooks` or `listStorybooks`
5. `listStories`
6. `openStory`
7. Poll readiness before `setControls` or mounted-story actions
8. `setControls`, `getScreen`, `getStoryActions`, and any changed action

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

## Embedded Visual Checks

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

## Updating Shared Guidance

When changing how agents should interact with Flipbook, update `getInstructions` in `workspace/flipbook-core/src/Agent/actions.luau`. Keep the response useful to agents running outside this repo:

- Explain that gateway actions are preferred over manual UI input.
- Explain when embedded visual checks are needed.
- Explain readiness rules such as polling controls before `setControls`.
- Explain Studio MCP blockers that external agents can recognize.

When changing a specific action, update that action's manifest metadata (`title`, `description`, and `inputSchema`) so `method = "list"` stays self-service. If the AgentGateway package cannot express the needed level of information, update AgentGateway rather than compensating in this skill.

