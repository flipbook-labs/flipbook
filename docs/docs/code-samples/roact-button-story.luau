local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Button = require(script.Parent.Button)

return {
	story = function()
		return Roact.createElement(Button, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
