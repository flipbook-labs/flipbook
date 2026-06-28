---
name: story-snapshot
description: Take screenshots of Flipbook stories in Roblox Studio for use in documentation. Use when asked to capture, screenshot, or photograph a Flipbook story, update docs screenshots, or document a UI component via its story.
---

# Story Snapshot

Captures screenshots of one or more Flipbook stories by driving Roblox Studio via the Studio MCP. All stories are captured in a single Play mode session — Play mode starts once and stays open for the entire batch.

## Inputs

- **`stories`** (required, one or more): The name(s) of the story to capture. Each name is entered into the Flipbook sidebar search to locate the story. If multiple results appear, the first match is used — pass a more specific name to disambiguate.

Screenshots are saved to `docs/screenshots/<story-name>.png` relative to the repo root.

## Saving captures to disk

The `screen_capture` MCP tool returns image data into the agent's context but gives the agent **no way to write those bytes to a file** — and OS-level screenshot paths (the `screencapture` CLI, computer-use, `osascript`) are routinely blocked by missing Screen Recording permission or a locked screen. Do not rely on them.

Instead, capture to disk with the bundled Lute script:

```
lute run .lute/tasks/capture-story.luau docs/screenshots/<story-name>.png <capture-id>
```

It connects to the StudioMCP proxy endpoint at `ws://127.0.0.1:13469/proxy`, sends a `proxy_hello` control message, waits for `tools_updated`, then calls `screen_capture` via MCP JSON-RPC (wrapped in `{"type":"json_rpc",...}`), base64-decodes the result, and writes the file — re-encoding to whatever format the output extension names. This needs no extra permissions, produces the exact viewport `screen_capture` would return, and completes in a few seconds with no arbitrary delays. The capture reflects whatever the running Studio is currently showing, so navigate to the target story **before** running the script.

## Phase 0: Setup

Run these steps once at the start of every invocation, regardless of how many stories are in the batch.

**Build the storybook place.** Run `lute run build storybook`. This outputs `build/flipbook-storybook.rbxl`.

**Open in Roblox Studio.** Call `list_roblox_studios` and `get_studio_state` to check if Studio already has `flipbook-storybook.rbxl` open. If it does, skip straight to the Play mode step. If not, open it — on macOS run `open build/flipbook-storybook.rbxl` via Bash (this command only works on macOS; on other platforms ask the user to open the file manually). After running `open`, poll `get_studio_state` starting after 1 second, then every 2 seconds, until Studio reports the place is loaded.

**Verify Flipbook is embedded.** Call `search_game_tree` looking for an instance named literally `"Flipbook"` (e.g. `ReplicatedStorage.Flipbook` or `StarterPlayerScripts.Flipbook` — the exact parent depends on where the user embedded it). When the Flipbook plugin's embed feature runs, it clones the plugin root (named `"Flipbook"`) into the place and tags it `"FlipbookRuntime"`. `FlipbookWorkspace` is the workspace stories folder and is NOT sufficient evidence that Flipbook is running. If no `"Flipbook"` instance is found, stop and tell the user: *"Flipbook is not embedded in this place. Open the Flipbook plugin in Studio and use its embed feature, then re-run the skill."*

**Set viewport to 16:9.** Before entering Play mode, call `screen_capture` and inspect the returned image dimensions. If the width and height do not form a clean 16:9 ratio (e.g. 1280×720, 1920×1080, 1366×768), resize the Studio game view. Use computer-use tools to drag the Studio window or game-view panel edges until a re-capture confirms a 16:9 size. 1280×720 is the preferred target — it is large enough to show Flipbook's sidebar and preview together without being oversized for docs. Once the dimensions are correct, proceed.

**Start Play mode.** Call `start_stop_play`.

**Create the output directory.** Run `mkdir -p docs/screenshots`.

## Phase 1: Per-Story Capture Loop

Repeat the following for each story name, without stopping or restarting Play mode between stories.

**Focus the search bar.** Click the `searchBar` coordinate from the Cached Coordinates section below. If the click misses — the story name you type does not appear in the search input — follow the coordinate regeneration instructions in that section, then retry.

**Type the story name.** Send `keyboard_input` for Ctrl+A (to clear any existing text), then type the story name.

**Select the story.** Click the `storyListFirstResult` coordinate to select the top result from the sidebar. If that coordinate misses, regenerate it using the instructions in the Cached Coordinates section.

**Capture.** Run `lute run .lute/tasks/capture-story.luau docs/screenshots/<story-name>.png <story-name>` (see "Saving captures to disk" above). Then verify the result by reading the saved file: confirm it shows the correct story with the full Flipbook UI. If something looks wrong, take a diagnostic `screen_capture`, compare against the cached coordinates, update them if the UI has moved, re-navigate, and re-run the capture script.

## Phase 2: Teardown

Call `start_stop_play` to exit Play mode. Print a summary listing all screenshot paths that were saved.

## Batch Guarantee

Never call `start_stop_play` between stories. If Play mode crashes mid-batch — detectable via `get_studio_state` returning an unexpected state — note which screenshots were already saved, call `start_stop_play` to restart Play mode, then resume the loop from the first story that hasn't been captured yet.

## Cached Coordinates

These pixel coordinates point to Flipbook UI elements in the Studio viewport. The agent updates this section in-place whenever coordinates are regenerated.

- searchBar: null
- storyListFirstResult: null

**If coordinates are `null`:** Take a `screen_capture` with Flipbook visible in Play mode. Locate the search input at the top of the Flipbook sidebar and the first item in the story list below it. Read the pixel (x, y) center of each element and update the values above before proceeding.

**If a click misses:** Take a `screen_capture`, find the element that was missed, read its new pixel (x, y) center from the screenshot, and update the coordinate above. Then retry the click.
