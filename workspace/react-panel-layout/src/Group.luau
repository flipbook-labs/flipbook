local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local useCallback = React.useCallback

local Dragger = require("@root/Dragger")
local GroupContext = require("@root/GroupContext")
local Panel = require("@root/Panel")

export type GroupProps = {
	fillDirection: Enum.FillDirection?,
} & Panel.PanelProps

local defaultProps = {
	minSize = 100,
	maxSize = math.huge,
	defaultSize = 200,
	fillDirection = Enum.FillDirection.Vertical,
}

type InternalProps = typeof(defaultProps) & GroupProps

local function Group(groupProps: GroupProps): React.Node
	local props: InternalProps = Sift.Dictionary.join(defaultProps, groupProps)

	local groupContext = GroupContext.use()
	local sizeBinding = groupContext.getPanelSize(props.id)
	local isHorizontal = groupContext.fillDirection == Enum.FillDirection.Horizontal

	local onDragStart = useCallback(function() end, {})
	local onDragContinue = useCallback(function() end, {})
	local onDragEnd = useCallback(function() end, {})

	return React.createElement(Foundation.View, {
		tag = {
			["auto-xy gap-small"] = true,
			["row"] = isHorizontal,
			["col"] = not isHorizontal,
		},
		sizeConstraint = {
			MinSize = Vector2.new(props.minSize, props.minSize),
			MaxSize = Vector2.new(props.maxSize, props.maxSize),
		},
		flexItem = {
			FlexMode = props.flexMode,
		},
		Size = if props.flexMode ~= Enum.UIFlexMode.Fill
			then sizeBinding:map(function(absoluteSize: number)
				return if isHorizontal then UDim2.new(0, absoluteSize, 1, 0) else UDim2.new(1, 0, 0, absoluteSize)
			end)
			else nil,
		LayoutOrder = props.LayoutOrder,
	}, {
		GroupWrapper = React.createElement(
			Foundation.View,
			{
				tag = {
					["auto-xy gap-medium"] = true,
					["row"] = isHorizontal,
					["col"] = not isHorizontal,
				},
				LayoutOrder = 1,
			},
			React.createElement(GroupContext.Provider, {
				fillDirection = props.fillDirection,
			}, props.children)
		),

		DraggerWrapper = React.createElement(Foundation.View, {
			tag = {
				["size-full-0 auto-y"] = isHorizontal,
				["size-0-full auto-x"] = not isHorizontal,
			},
			sizeConstraint = {
				MaxSize = sizeBinding:map(function(size: number)
					return Vector2.one * size
				end),
			},
			LayoutOrder = 2,
		}, {
			Dragger = React.createElement(Dragger, {
				onDragStart = onDragStart,
				onDrag = onDragContinue,
				onDragEnd = onDragEnd,
			}),
		}),
	})
end

return React.memo(Group)
