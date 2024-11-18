local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local RoactButton = require(script.Parent.RoactButton)

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
