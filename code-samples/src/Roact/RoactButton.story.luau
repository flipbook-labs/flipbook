local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local RoactButton = require(script.Parent.RoactButton)

return {
	story = function()
		return Roact.createElement(RoactButton, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
