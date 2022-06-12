local styles = {}

styles.CORNER_SM = UDim.new(0, 2)
styles.CORNER_MD = UDim.new(0, 6)
styles.CORNER_FL = UDim.new(0.5, 0)

styles.PADDING_SM = UDim.new(0, 10)
styles.PADDING_MD = UDim.new(0, 16)
styles.PADDING_LG = UDim.new(0, 20)
styles.PADDING_XL = UDim.new(0, 30)

styles.TextLabel = {
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	LineHeight = 1.25,
	RichText = true,
	Size = UDim2.fromScale(0, 0),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}

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
	ScrollBarThickness = 4,
	BackgroundTransparency = 1,
}

return styles
