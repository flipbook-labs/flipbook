local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("./GroupContext")

export type PanelProps = {
	id: string?,
	LayoutOrder: number?,
	minSize: Vector2?,
	maxSize: Vector2?,
	defaultSize: Vector2?,
	children: React.Node?,
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
	local isHorizontal = groupContext.fillDirection == Enum.FillDirection.Horizontal

	local panelId = props.id
	if panelId then
		groupContext.registerPanel(panelId, {
			minSize = props.minSize,
			maxSize = props.maxSize,
		})
	end

	local storedPixels = if panelId then groupContext.sizes[panelId] else nil
	local pixelSize = storedPixels or (if isHorizontal then props.defaultSize.X else props.defaultSize.Y)
	local size = if isHorizontal
		then UDim2.new(0, pixelSize, 1, 0)
		else UDim2.new(1, 0, 0, pixelSize)

	return React.createElement(Foundation.ScrollView, {
		tag = {
			["padding-medium bg-surface-300"] = true,
		},
		Size = size,
		sizeConstraint = {
			MinSize = props.minSize,
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
