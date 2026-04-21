local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("./GroupContext")
local Dragger = require("./Dragger")

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
	hasDragHandle = false,
}

type Props = typeof(defaultProps) & PanelProps

local function Panel(panelProps: PanelProps)
	local props: Props = Sift.Dictionary.join(defaultProps, panelProps)

	local groupContext = GroupContext.use()
	local isHorizontal = groupContext.fillDirection == Enum.FillDirection.Horizontal

	return React.createElement(Foundation.View, {
		tag = "size-full grow",
		LayoutOrder = props.LayoutOrder,
		sizeConstraint = props.sizeConstraint,
	}, {
		Content = React.createElement(Foundation.View, {
			tag = "auto-xy",
		}, props.children),

		DragHandle = if props.hasDragHandle then React.createElement(Dragger, {}) else nil,
	})
end

return Panel
