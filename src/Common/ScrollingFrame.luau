local React = require("@pkg/react")
local Sift = require("@pkg/sift")
local useTheme = require("@root/Common/useTheme")

export type Props = {
	[string]: any,
}

local ScrollingFrame = React.forwardRef(function(props: Props, ref: any)
	local theme = useTheme()

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
		ref = ref,
	}, props)

	return React.createElement("ScrollingFrame", props)
end)

return ScrollingFrame
