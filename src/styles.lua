local Llama = require(script.Parent.Packages.Llama)

local styles = {}

styles.PADDING = UDim.new(0, 8)
styles.LARGE_PADDING = UDim.new(0, 16)
styles.SMALL_PADDING = UDim.new(0, 4)

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

styles.Header = Llama.Dictionary.join(styles.TextLabel, {
	Font = Enum.Font.GothamBold,
	TextSize = styles.TextLabel.TextSize * 1.25,
})

styles.ScrollingFrame = {
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.fromScale(1, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollBarThickness = 3,
	BackgroundTransparency = 1,
}

return styles
