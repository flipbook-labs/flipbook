local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local FusionButton = require(script.Parent.FusionButton)

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
