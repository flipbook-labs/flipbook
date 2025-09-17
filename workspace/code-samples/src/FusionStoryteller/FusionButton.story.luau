local Storyteller = require("@pkg/Storyteller")

local FusionButton = require("./FusionButton")

local story: Storyteller.Story<any> = {
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
