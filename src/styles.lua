local styles = {}

styles.TextLabel = {
	TextSize = 16,
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Size = UDim2.fromScale(0, 0),
	AutomaticSize = Enum.AutomaticSize.XY,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	BackgroundTransparency = 1,
}

styles.ScrollingFrame = {
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.fromScale(1, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
}

return styles
