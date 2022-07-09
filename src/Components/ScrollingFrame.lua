local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local useTailwind = require(flipbook.Hooks.useTailwind)

export type Props = {
	[string]: any,
}

local function ScrollingFrame(props: Props)
	props = Llama.Dictionary.join({
		Size = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(1, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = useTailwind("gray-800"),
		ScrollBarThickness = 4,
		ScrollBarImageTransparency = 0.2,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}, props)

	return Roact.createElement("ScrollingFrame", props)
end

return ScrollingFrame
