local Storyteller = require("@pkg/Storyteller")

local FusionButton = require("./FusionButton")

local story: Storyteller.Story<unknown> = {
	story = function()
		return FusionButton({
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
