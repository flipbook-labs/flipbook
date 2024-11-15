return {
	story = function()
		local button = Instance.new("TextButton")
		button.Text = "Button"
		button.Font = Enum.Font.BuilderSansBold
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Size = UDim2.fromOffset(200, 40)

		return button
	end,
}
