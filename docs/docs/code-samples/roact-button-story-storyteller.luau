local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local Button = require(script.Parent.Button)

local story: Storyteller.Story<any> = {
	story = function()
		return Roact.createElement(Button, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
