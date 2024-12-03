local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Storyteller = require(ReplicatedStorage.Packages.Storyteller)

local ReactButton = require(script.Parent.ReactButton)

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
