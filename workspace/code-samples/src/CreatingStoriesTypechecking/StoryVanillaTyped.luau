local Storyteller = require("@pkg/Storyteller")

local story: Storyteller.Story<any> = {
	summary = "A basic button component.",
	story = function(_props)
		local button = Instance.new("TextButton")
		button.Text = "Click Me"
		return button
	end,
}

return story
