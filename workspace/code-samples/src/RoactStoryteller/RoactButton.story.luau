local Roact = require("@pkg/Roact")
local Storyteller = require("@pkg/Storyteller")

local RoactButton = require("./RoactButton")

local story: Storyteller.Story<any> = {
	story = function()
		return Roact.createElement(RoactButton, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
