local Llama = require(script.Parent.Packages.Llama)

local styles = {}

styles.PADDING = UDim.new(0, 10)
styles.LARGE_PADDING = UDim.new(0, 20)
styles.SMALL_PADDING = UDim.new(0, 5)

styles.TextLabel = {
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	LineHeight = 1.25,
	RichText = true,
	Size = UDim2.fromScale(0, 0),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}

styles.Header = Llama.Dictionary.join(styles.TextLabel, {
	Font = Enum.Font.GothamBold,
	TextSize = styles.TextLabel.TextSize * 1.25,
})

styles.Icon = {
	BackgroundTransparency = 1,
	ImageColor3 = Color3.new(1, 1, 1),
	Size = UDim2.fromOffset(16, 16),
}

styles.ScrollingFrame = {
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.fromScale(1, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollBarThickness = 3,
	BackgroundTransparency = 1,
}

return styles
