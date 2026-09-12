# Embedded Play-mode checks

Use this workflow when a Flipbook check needs viewport screenshots or virtual mouse and keyboard input. Run semantic gateway actions in Edit mode first; the embedded client is the visual and input surface.

1. Invoke `embedFlipbook` through `CoreGui.FlipbookAgentGateway`. Omit `parent` to use `ReplicatedStorage`, and leave `overwrite` false unless replacing an existing embedded runtime is intended.
2. Start Play mode with `start_stop_play`, then poll `get_studio_state` until the Client data model is available.
3. Find the embedded UI under `LocalPlayer.PlayerGui.Flipbook` and wait for its target story or control to appear. Do not substitute a blank or loading capture for evidence.
4. Use `screen_capture` for visual evidence.
5. When no gateway action covers an interaction, use `user_mouse_input` or `user_keyboard_input` against a discovered Client instance path. Treat repeated fallback interactions as candidates for a focused gateway action.
6. Inspect Client console errors when the UI does not mount or react as expected.
7. Stop Play mode when finished unless the user asks to leave the experience running.

Embedding mutates the open place. Do not pass `overwrite = true`, save the place, or replace an existing runtime without authorization.
