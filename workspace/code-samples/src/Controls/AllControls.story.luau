local Storyteller = require("@pkg/Storyteller")

local controls = {
	label = "Click Me",
	isDisabled = false,
	count = Storyteller.createNumberControl(3),
	textSize = Storyteller.createSliderControl(16, NumberRange.new(8, 32), 1),
	weight = Storyteller.createSelectControl({ "Light", "Regular", "Bold" }),
	alignment = Storyteller.createRadioControl({ "Left", "Center", "Right" }),
	decorations = Storyteller.createMultiSelectControl({ "Shadow", "Outline", "Glow" }),
	extras = Storyteller.createCheckControl({ "Icon", "Badge" }),
	backgroundColor = Storyteller.createColorControl(Color3.fromRGB(255, 255, 255)),
	publishedAt = Storyteller.createDateControl(),
	target = Storyteller.createObjectControl(),
}

type Props = {
	controls: { [string]: any },
}

return {
	summary = "One control of every type Flipbook supports",
	controls = controls,
	story = function(props: Props)
		local button = Instance.new("TextButton")
		button.Text = if props.controls.isDisabled then "Disabled" else props.controls.label
		button.TextSize = props.controls.textSize
		button.Font = Enum.Font.BuilderSansExtraBold
		button.TextColor3 = Color3.fromRGB(50, 50, 50)
		button.BackgroundColor3 = props.controls.backgroundColor
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
