local flipbook = script:FindFirstAncestor("flipbook")

local Sift = require(flipbook.Packages.Sift)
local Roact = require(flipbook.Packages.Roact)
local useTheme = require(flipbook.Hooks.useTheme)
local hook = require(flipbook.hook)

export type Props = {
	[string]: any,
}

local function ScrollingFrame(props: Props, hooks: any)
	local theme = useTheme(hooks)

	props = Sift.Dictionary.merge({
		Size = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(1, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = theme.scrollbar,
		ScrollBarThickness = 4,
		ScrollBarImageTransparency = 0.2,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}, props)

	return Roact.createElement("ScrollingFrame", props)
end

return hook(ScrollingFrame)
