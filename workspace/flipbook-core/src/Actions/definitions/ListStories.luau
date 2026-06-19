local types = require("@root/Actions/types")

local ListStories: types.Action = {
	id = "Flipbook/ListStories",
	text = "List Stories",
	statusTip = "Return the available stories that can be opened with SelectStory",
	allowBinding = false,
	run = function(ctx)
		return ctx.controller.listStories()
	end,
}

return ListStories
