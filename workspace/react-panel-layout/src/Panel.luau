local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Dragger = require("./Dragger")
local GroupContext = require("./GroupContext")

local useCallback = React.useCallback

type SizeConstraint = {
	MinSize: Vector2,
	MaxSize: Vector2,
}

export type PanelProps = {
	LayoutOrder: number?,
	sizeConstraint: SizeConstraint?,
	hasDragHandle: boolean?,
	children: React.Node?,
}

local defaultProps = {
	sizeConstraint = {
		MinSize = Vector2.new(200, 100),
		MaxSize = Vector2.new(800, math.huge),
	},
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

	local minSize = props.sizeConstraint.MinSize
	local maxSize = props.sizeConstraint.MaxSize

	return React.createElement(Foundation.View, {
		tag = {
			["row"] = isHorizontal,
			["col"] = not isHorizontal,
			["auto-xy"] = true,
		},
		LayoutOrder = props.LayoutOrder,
	}, {
		Panel = React.createElement(Foundation.View, {
			tag = {
				["row"] = isHorizontal,
				["col"] = not isHorizontal,
				["size-full padding-medium bg-surface-300"] = true,
			},
			sizeConstraint = {
				MinSize = dragDelta:map(function(delta: Vector2)
					return if isHorizontal
						then Vector2.new(math.min(minSize.X, minSize.X + delta.X), 0)
						else Vector2.new(0, math.min(minSize.Y, minSize.Y + delta.Y))
				end),
				MaxSize = dragDelta:map(function(delta: Vector2)
					return if isHorizontal
						then Vector2.new(math.max(maxSize.X, maxSize.X + delta.X), math.huge)
						else Vector2.new(math.huge, math.max(maxSize.Y, maxSize.Y + delta.Y))
				end),
			},
			LayoutOrder = 1,
		}, props.children),

		DragHandle = React.createElement(Dragger, {
			LayoutOrder = 2,
			onDrag = onDrag,
		}),
	})
end

return Panel
