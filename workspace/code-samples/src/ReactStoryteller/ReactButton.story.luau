local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ReactButton = require("./ReactButton")

local story: Storyteller.Story<any> = {
	story = function()
		return React.createElement(ReactButton, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
