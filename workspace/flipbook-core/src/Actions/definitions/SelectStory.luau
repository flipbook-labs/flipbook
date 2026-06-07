local types = require("@root/Actions/types")

local SelectStory: types.Action = {
	id = "Flipbook/SelectStory",
	text = "Select Story",
	statusTip = "Open a story by its full path",
	-- Contextual; needs a payload, so not useful as a static shortcut.
	allowBinding = false,
	params = {
		{
			name = "path",
			type = "string",
			required = true,
			description = "Story path as returned by ListStories (slash-separated, e.g. ReplicatedStorage/Button.story)",
		},
	},
	run = function(ctx, payload)
		assert(typeof(payload) == "table" and typeof(payload.path) == "string", "payload.path (string) is required")
		return ctx.controller.selectStory(payload.path)
	end,
}

return SelectStory
