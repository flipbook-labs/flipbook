local controls = {
	isDisabled = false,
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	story = function(props: Props)
		local button = Instance.new("TextButton")
		button.Text = if props.controls.isDisabled then "Disabled" else "Click Me"
		button.TextSize = 16
		button.Font = Enum.Font.BuilderSansExtraBold
		button.TextColor3 = Color3.fromRGB(50, 50, 50)
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		button.AutoButtonColor = not props.controls.isDisabled
		button.BorderSizePixel = 0
		button.Size = UDim2.fromOffset(200, 40)

		button.Activated:Connect(function()
			if not props.controls.isDisabled then
				print("clicked")
			end
		end)

		return button
	end,
}
