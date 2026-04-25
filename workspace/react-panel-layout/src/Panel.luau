local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local useEffect = React.useEffect

local GroupContext = require("./GroupContext")

export type PanelProps = {
	id: string,

	flexMode: Enum.UIFlexMode?,
	minSize: Vector2?,
	maxSize: Vector2?,
	defaultSize: Vector2?,
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
	local isHorizontal = groupContext.fillDirection == Enum.FillDirection.Horizontal

	local panelId = props.id

	useEffect(function()
		if not panelId then
			return
		end
		groupContext.registerPanel(panelId, {
			minSize = props.minSize,
			maxSize = props.maxSize,
		})
		return function()
			groupContext.unregisterPanel(panelId)
		end
	end, { panelId, props.minSize, props.maxSize } :: { unknown })

	local storedPixels = if panelId then groupContext.sizes[panelId] else nil
	local pixelSize = storedPixels or (if isHorizontal then props.defaultSize.X else props.defaultSize.Y)
	local size = if isHorizontal then UDim2.new(0, pixelSize, 1, 0) else UDim2.new(1, 0, 0, pixelSize)

	return React.createElement(Foundation.ScrollView, {
		tag = "padding-medium bg-surface-300",
		Size = size,
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
