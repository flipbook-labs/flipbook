local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local Button = require(script.Parent.Button)

local story: Storyteller.Story<any> = {
	story = function()
		return React.createElement(Button, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
