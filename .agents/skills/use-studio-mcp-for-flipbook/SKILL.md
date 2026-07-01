---
name: use-studio-mcp-for-flipbook
description: Verify Flipbook inside an open Roblox Studio session using the built-in StudioMCP JSON-RPC binary. Use when testing the Flipbook plugin, AgentGateway actions, execute_luau, CoreGui.FlipbookAgentGateway, or any Studio-side behavior where Cursor's MCP tool descriptors are unavailable or stale.
---

# Use StudioMCP For Flipbook

## When To Use

Use this skill when validating Flipbook in Roblox Studio, especially AgentGateway flows. Do not assume Cursor's MCP descriptor files are authoritative; they can show an errored server even when StudioMCP works directly.

## Connect Directly

On macOS, StudioMCP is:

```bash
/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP
```

It speaks newline-delimited JSON-RPC over stdio, not `Content-Length` framing. Send one JSON object per line.

Required startup:

1. Send `initialize` with protocol version `2024-11-05`.
2. Send `notifications/initialized`.
3. Call tools with `tools/call`.

Useful tools:

- `tools/list` - inspect available tools.
- `get_studio_state` - confirm Edit/Client/Server data models.
- `search_game_tree` - warm up/select a Studio instance and inspect plugin instances.
- `execute_luau` - run Luau in Studio. Use `datamodel_type = "Edit"` for plugin checks.
- `get_console_output` - inspect runtime errors when playtesting.

If `get_studio_state` says no active Studio instance, call `search_game_tree` against `PluginDebugService` or `Workspace`, then retry `get_studio_state`. The proxy may lazily choose an active Studio instance after a tree search.

## Minimal Python Client

Use this shape for direct calls from the repo root:

```python
import json, subprocess

proc = subprocess.Popen(
    ["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    text=True,
    bufsize=1,
)

def send(message):
    proc.stdin.write(json.dumps(message, separators=(",", ":")) + "\n")
    proc.stdin.flush()

send({
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
        "protocolVersion": "2024-11-05",
        "capabilities": {},
        "clientInfo": {"name": "flipbook-probe", "version": "0.1.0"},
    },
})
print(proc.stdout.readline())
send({"jsonrpc": "2.0", "method": "notifications/initialized"})
```

For multi-call probes, keep one StudioMCP process alive for the full validation script. Starting a new process for each call can lose active-instance state.

## Flipbook Gateway Validation Order

Before testing visual actions, build and open the plugin:

```bash
lute run build plugin --channel dev --clean
```

Then use `execute_luau` in the Edit data model to probe the gateway:

```lua
local CoreGui = game:GetService("CoreGui")
local gateway = CoreGui:FindFirstChild("FlipbookAgentGateway")
assert(gateway ~= nil, "missing FlipbookAgentGateway")
```

Always open the widget before validating visual behavior:

```lua
gateway:Invoke({ method = "call", action = "openWidget" })
```

Recommended action sequence:

1. `openWidget`
2. `list` manifest request
3. `listStorybooks`
4. `listStories`
5. `openStory`
6. Wait briefly (`task.wait()`) for React to mount the story view.
7. `setControls` if the story has controls.
8. `navigate` / `getScreen`

`setControls` requires the story view to be mounted. If it returns `setControls requires the story view to be mounted`, open the widget, open a story, wait a frame, and retry.

`embedFlipbook` mutates the place by cloning the runtime into `ReplicatedStorage` by default. Only call it when the user wants embed behavior tested. A second call without `overwrite = true` should fail with the existing runtime path.

## Example Gateway Probe

```lua
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local gateway = CoreGui:FindFirstChild("FlipbookAgentGateway")

local function call(action, params)
    return gateway:Invoke({ method = "call", action = action, params = params })
end

local result = {}
result.widget = call("openWidget")
result.manifest = gateway:Invoke({ method = "list" })
result.storybooks = call("listStorybooks")
return HttpService:JSONEncode(result)
```

