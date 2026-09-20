type Props = {
	container: Instance,
}

return {
	story = function(props: Props)
		local button = Instance.new("TextButton")
		button.Text = "Click Me"
		button.TextSize = 16
		button.Font = Enum.Font.BuilderSansExtraBold
		button.TextColor3 = Color3.fromRGB(50, 50, 50)
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		button.BorderSizePixel = 0
		button.Size = UDim2.fromOffset(200, 40)
		button.Parent = props.container

		button.Activated:Connect(function()
			print("clicked")
		end)

		return function()
			button:Destroy()
		end
	end,
}
