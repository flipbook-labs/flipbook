local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("./GroupContext")

export type PanelProps = {
	flexMode: Enum.UIFlexMode?,
	minSize: Vector2?,
	maxSize: Vector2?,
	defaultSize: Vector2?,
	size: UDim2?,
	children: React.Node?,
	LayoutOrder: number?,
}

local defaultProps = {
	minSize = Vector2.new(100, 100),
	maxSize = Vector2.new(math.huge, math.huge),
	defaultSize = Vector2.new(200, 200),
}

type Props = typeof(defaultProps) & PanelProps

local function Panel(panelProps: PanelProps)
	local props: Props = Sift.Dictionary.join(defaultProps, panelProps)

	local groupContext = GroupContext.use()

	return React.createElement(Foundation.ScrollView, {
		tag = "padding-medium bg-surface-300",
		Size = props.size,
		sizeConstraint = {
			MinSize = props.minSize,
		},
		flexItem = {
			FlexMode = props.flexMode,
		},
		scroll = {
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			CanvasSize = UDim2.fromScale(0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		},
		layout = {
			FillDirection = groupContext.fillDirection,
		},
		LayoutOrder = props.LayoutOrder,
	}, props.children)
end

return React.memo(Panel)
