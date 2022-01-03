local Roact = require(script.Parent.Parent.Packages.Roact)

return {
	story = Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(228, 32, 114),
	}, {
		Label = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			TextScaled = true,
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = "Hello World!",
		}),
	}),
}
