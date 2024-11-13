local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local Button = require(script.Parent.Button)

return {
	story = function()
		return React.createElement(Button, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
