local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Dragger = require("./Dragger")
local GroupContext = require("./GroupContext")

local useCallback = React.useCallback

export type PanelProps = {
	LayoutOrder: number?,
	minSize: Vector2?,
	maxSize: Vector2?,
	defaultSize: Vector2?,
	hasDragHandle: boolean?,
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
	local dragDelta, setDragDelta = React.useBinding(Vector2.new(0, 0))

	local onDrag = useCallback(function(delta: Vector2)
		setDragDelta(delta)
	end, {})

	-- I think a panel's min size should be in order of...
	-- 1. The min size specified as props
	-- 3. The size of the panel's contents

	return React.createElement(Foundation.ScrollView, {
		tag = {
			["auto-xy fill padding-medium bg-surface-300"] = true,
		},
		-- NOTE: Remember that fillDirection needs to be what takes control
		-- here. Otherwise panels will stack off screen. We have to make
		-- sure whichever direction we're filling that we stay within
		-- bounds, which flex should take care of. Maybe I should be using
		-- GrowRatio
		sizeConstraint = {
			MinSize = props.minSize,
			MaxSize = dragDelta:map(function(delta: Vector2)
				return Vector2.new(
					math.min(props.maxSize.X, props.maxSize.X + delta.X),
					math.min(props.maxSize.Y, props.maxSize.Y + delta.Y)
				)
			end),
		},
		scroll = {
			AutomaticSize = Enum.AutomaticSize.XY,
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
