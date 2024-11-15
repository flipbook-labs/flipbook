local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local ReactButton = require(script.Parent.ReactButton)

return {
	story = function()
		return React.createElement(ReactButton, {
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
