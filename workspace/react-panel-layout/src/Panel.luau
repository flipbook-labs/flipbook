local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("@root/GroupContext")

local useEffect = React.useEffect
export type PanelProps = {
	id: string,
	flexMode: Enum.UIFlexMode?,
	defaultSize: number?,
	minSize: number?,
	maxSize: number?,
	children: React.Node?,
	LayoutOrder: number?,
}

local defaultProps = {
	defaultSize = 300,
	minSize = 200,
	maxSize = math.huge,
	flexMode = Enum.UIFlexMode.None,
}

type Props = typeof(defaultProps) & PanelProps

local function Panel(panelProps: PanelProps)
	local props: Props = Sift.Dictionary.join(defaultProps, panelProps)

	local groupContext = GroupContext.use()
	local isHorizontal = groupContext.fillDirection == Enum.FillDirection.Horizontal
	local size = groupContext.getPanelSize(props.id)

	useEffect(function()
		groupContext.registerPanel(props.id, {
			defaultSize = props.defaultSize,
			minSize = props.minSize,
			maxSize = props.maxSize,
			flexMode = props.flexMode,
		})

		return function()
			groupContext.unregisterPanel(props.id)
		end
	end, { props.id, props.defaultSize, props.minSize, props.maxSize, props.flexMode } :: { unknown })

	return React.createElement(Foundation.ScrollView, {
		tag = "auto-xy padding-medium bg-surface-300",
		sizeConstraint = {
			MinSize = Vector2.new(props.minSize, props.minSize),
			MaxSize = Vector2.new(props.maxSize, props.maxSize),
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
		Size = if props.flexMode ~= Enum.UIFlexMode.Fill
			then size:map(function(absoluteSize: number)
				return if isHorizontal then UDim2.new(0, absoluteSize, 1, 0) else UDim2.new(1, 0, 0, absoluteSize)
			end)
			else nil,
		LayoutOrder = props.LayoutOrder,
	}, props.children)
end

return React.memo(Panel)
