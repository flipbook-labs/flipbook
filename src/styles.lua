local styles = {}

styles.PADDING = UDim.new(0, 8)
styles.LARGE_PADDING = UDim.new(0, 16)
styles.SMALL_PADDING = UDim.new(0, 4)

styles.TextLabel = {
	AnchorPoint = Vector2.new(0, 0),
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

styles.ScrollingFrame = {
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.fromScale(1, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollBarThickness = 3,
	BackgroundTransparency = 1,
}

return styles
