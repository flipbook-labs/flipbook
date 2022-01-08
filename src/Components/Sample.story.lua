local Roact = require(script.Parent.Parent.Packages.Roact)

return {
	summary = "This is a sample story to show off how to write one!",
	controls = {
		["Message content"] = "Hello, World!",
		["Use alt color"] = false,
	},
	roact = Roact,
	story = function(props)
		local color = if props.controls["Use alt color"]
			then Color3.fromRGB(68, 32, 228)
			else Color3.fromRGB(228, 32, 114)

		return Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = color,
		}, {
			Label = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				TextScaled = true,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Text = props.controls["Message content"],
			}),
		})
	end,
}
