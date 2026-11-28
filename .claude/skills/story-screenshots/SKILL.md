---
name: story-screenshots
description: "Capture screenshots of Flipbook Stories in Roblox Studio and attach them to a pull request. Use when: a pull request changes what people see or how they interact with Flipbook, Greptile's visual-evidence rule flags a pull request, or someone asks for screenshots of a Story for a pull request or the docs."
---

# Story Screenshots

A reviewer of a visible change needs to see the result, so a pull request that changes what people see in Flipbook carries screenshots or video in its body. Greptile's `visual-evidence` rule flags one that doesn't. This skill covers what to capture, how to save it from Studio, and how to get it into the pull request.

## What to capture

Capture each Story the change affects, in the state that shows the change. When the change alters UI that already exists, capture the same Story from `main`'s build too, and show them as before and after. When the change depends on the theme, capture light and dark.

Every image is evidence of something, so check each one before using it. A blank, loading, or solid-color capture isn't evidence.

## Capture

The [`use-studio-mcp`](../use-studio-mcp/SKILL.md) skill covers building Flipbook, opening the Storybook place, embedding Flipbook, and driving it through `FlipbookAgentGateway`. Studio MCP's `screen_capture` leaves out plugin widgets and anything under `CoreGui`. On a build with the `openViewport` gateway action, call it to move Flipbook into the viewport, capture in Edit mode, and call `openWidget` afterward, as `use-studio-mcp` describes. Otherwise, capture Flipbook embedded in Play mode:

1. Build the plugin and the Storybook place, open the place, and call `embedFlipbook` from the plugin's gateway.
2. Start Play mode. In the Client data model, the embedded gateway is `LocalPlayer.PlayerGui.FlipbookAgentGateway`.
3. Call `openStory`, then poll `getCurrentStory` until `isMounted` is true. Set any controls the shot needs with `setControls`. Sidebar state, such as an expanded folder, needs simulated input, as `use-studio-mcp` describes.
4. Save the viewport to a file:

   ```sh
   lute run screenshot build/screenshots/<story>.png
   ```

   [`screenshot`](../../../.lute/screenshot.luau) calls Studio MCP's `screen_capture` itself and writes the image, because the tool returns the image to the agent without saving it. Pass `--studio <id>` when more than one Studio is open. On Windows, pass `--studio-mcp` with the path to Studio's `StudioMCP` program, and write a `.jpg`. Studio captures JPEG, and converting to any other format uses `sips`, which only ships with macOS.

5. Open the file and check that it shows the Story you meant, fully rendered.

Capture every Story in one Play session. When you're done, stop Play mode and remove the embedded runtime from `ReplicatedStorage`. Don't save the place.

## Attach

GitHub has no API for adding an image to a pull request body. It hosts an image when someone drops it into a comment box, and the resulting `https://github.com/user-attachments/assets/…` URL works anywhere on GitHub. So attaching takes a browser where the person is signed in to GitHub, and a browser tool that can set a file input, such as Claude in Chrome's `file_upload` or Chrome DevTools' `upload_file`.

1. Open the pull request page.
2. Find the comment box's file input. GitHub's newer comment box has no file input until someone clicks its "Paste, drop, or click to add files" button, and that click opens the system's file picker, which a browser tool can't drive. Run this in the page instead. It makes the button's file input appear in the page without opening the picker:

   ```js
   const click = HTMLInputElement.prototype.click;
   window.agentDraft = document.querySelector(
   	'textarea[aria-label="Markdown value"]',
   ).value;
   HTMLInputElement.prototype.click = function () {
   	if (this.type !== "file") return click.call(this);
   	HTMLInputElement.prototype.click = click;
   	this.id = "agent-file-input";
   	if (!this.isConnected) document.body.append(this);
   };
   [...document.querySelectorAll("button")]
   	.find((button) =>
   		button.textContent
   			.trim()
   			.startsWith("Paste, drop, or click to add files"),
   	)
   	.click();
   ```

3. Give `#agent-file-input` the image with the browser tool. Chrome DevTools only reads files under `$TMPDIR`, so copy the image there first.
4. Read the comment box, `textarea[aria-label="Markdown value"]`, until it holds an `<img>` tag with a `user-attachments` URL.
5. Never submit the comment. Put the box back the way it was, because GitHub keeps the draft and shows it again later. The snippet in step 2 saved any text the person had already typed, and this restores it:

   ```js
   const ta = document.querySelector('textarea[aria-label="Markdown value"]');
   Object.getOwnPropertyDescriptor(
   	HTMLTextAreaElement.prototype,
   	"value",
   ).set.call(ta, window.agentDraft ?? "");
   ta.dispatchEvent(new Event("input", { bubbles: true }));
   ```

6. Put the images in the pull request template's Visuals section, which sits between Solution and Testing, with a line before each one saying what it shows. Lay out a before and after as a two-column table.

If no browser is available, don't skip the evidence silently. Say in Testing which screenshots were captured and where they are, so the person can attach them.

## Re-verify

**Re-verify these claims when this skill next loads.** Run these from the repo root. A command that fails or prints nothing means the skill needs updating:

```sh
ls .lute/screenshot.luau
git grep -n '"visual-evidence"' -- .greptile/config.json
git grep -n -E "openStory|setControls|getCurrentStory|embedFlipbook" -- workspace/flipbook-agents/src/actions/init.luau
```
