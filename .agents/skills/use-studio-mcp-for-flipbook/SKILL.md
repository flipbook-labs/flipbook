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

Keep one StudioMCP process alive for the whole validation script. The proxy can lose its selected Studio instance between separate processes, so prefer one script that initializes, warms up Studio selection, executes Luau, and reads console output before exiting.

Useful tools:

- `tools/list` - inspect available tools.
- `get_studio_state` - confirm Edit/Client/Server data models.
- `search_game_tree` - warm up/select a Studio instance and inspect plugin instances.
- `execute_luau` - run Luau in Studio. Use `datamodel_type = "Edit"` for plugin checks.
- `get_console_output` - inspect runtime errors when playtesting.

If `get_studio_state` says no active Studio instance, call `search_game_tree` against `Workspace`, then `PluginDebugService`, then retry `get_studio_state` or continue with the intended tool call in the same process. The proxy may lazily choose an active Studio instance after a tree search, and a single "no active Studio instance" response is not always terminal.

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
    if "id" in message:
        return json.loads(proc.stdout.readline())

def call_tool(name, arguments=None):
    request_id = call_tool.next_id
    call_tool.next_id += 1
    return send({
        "jsonrpc": "2.0",
        "id": request_id,
        "method": "tools/call",
        "params": {"name": name, "arguments": arguments or {}},
    })

call_tool.next_id = 2

print(send({
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
        "protocolVersion": "2024-11-05",
        "capabilities": {},
        "clientInfo": {"name": "flipbook-probe", "version": "0.1.0"},
    },
}))
send({"jsonrpc": "2.0", "method": "notifications/initialized"})

# Warm up active Studio selection before execute_luau/get_console_output.
call_tool("search_game_tree", {"path": "Workspace", "head_limit": 5, "max_depth": 1})
call_tool("search_game_tree", {"path": "PluginDebugService", "head_limit": 5, "max_depth": 2})
```

For longer scripts, increment the JSON-RPC id for each request. Always read one response line for each request with an `id`; notifications do not produce responses.

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
6. Wait briefly (`task.wait()`) for the story view to mount.
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

Gateway `method = "call"` responses are wrapped. Successful calls usually return a table shaped like `{ ok = true, result = ... }`; failed calls return `{ ok = false, error = ... }`. When chaining calls, read from `response.result` rather than assuming the action payload is the top-level table.

## Console Output Checks

`get_console_output` returns cumulative Studio output and may be truncated. Print a unique marker before and after the action under test, then inspect only the output between those markers:

```lua
local marker = "FLIPBOOK_PROBE_" .. tostring(os.clock())
print(marker .. "_START")
-- perform gateway actions here
print(marker .. "_END")
```

Use stable, unique marker text for each probe run so stale output from previous runs does not get mistaken for fresh output.

