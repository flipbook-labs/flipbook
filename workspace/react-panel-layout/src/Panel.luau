local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("./GroupContext")

export type PanelProps = {
	flexMode: Enum.UIFlexMode?,
	minSize: Vector2?,
	maxSize: Vector2?,
	defaultSize: Vector2?,
	children: React.Node?,
	LayoutOrder: number?,
}

local defaultProps = {
	minSize = Vector2.new(200, 200),
	maxSize = Vector2.new(math.huge, math.huge),
	defaultSize = Vector2.new(200, 200),
}

type InternalProps = { id: string } & PanelProps
type Props = typeof(defaultProps) & InternalProps

local function Panel(panelProps: InternalProps)
	local props: Props = Sift.Dictionary.join(defaultProps, panelProps)

	local groupContext = GroupContext.use()
	local isHorizontal = groupContext.fillDirection == Enum.FillDirection.Horizontal

	local lastSize = groupContext.sizes[props.id]
	local pixelSize = if lastSize then lastSize else (if isHorizontal then props.defaultSize.X else props.defaultSize.Y)
	local size = if isHorizontal then UDim2.new(0, pixelSize, 1, 0) else UDim2.new(1, 0, 0, pixelSize)

	return React.createElement(Foundation.ScrollView, {
		tag = "padding-medium bg-surface-300",
		Size = size,
		sizeConstraint = {
			MinSize = props.minSize,
			MaxSize = props.maxSize,
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
