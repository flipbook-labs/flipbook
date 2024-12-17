local React = require("@pkg/React")
local ReactSpring = require("@pkg/ReactSpring")

local Sprite = require("@root/Common/Sprite")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local assets = require("@root/assets")
local constants = require("@root/constants")
local types = require("@root/TreeView/types")
local usePinnedInstances = require("@root/TreeView/usePinnedInstances")
local useTheme = require("@root/Common/useTheme")
local useTreeNodeIcon = require("@root/TreeView/useTreeNodeIcon")

local useSpring = ReactSpring.useSpring :: any
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState

type TreeNode = types.TreeNode

local function countParents(node: TreeNode): number
	local current = node
	local count = 0
	while current.parent do
		current = current.parent
		count += 1
	end
	return count
end

export type Props = {
	node: TreeNode,
	onActivated: (() -> ())?,
	layoutOrder: number?,
}

local function TreeNode(props: Props)
	local theme = useTheme()
	local icon, iconColor = useTreeNodeIcon(props.node.icon)
	local isHovered, setIsHovered = useState(false)
	local treeViewContext = TreeViewContext.use()
	local isExpanded = treeViewContext.isExpanded(props.node)
	local isSelected = treeViewContext.isSelected(props.node)
	local pinning = usePinnedInstances()

	local styles = useSpring({
		hover = if isHovered or isSelected then 0 else 1,
		expand = if isExpanded then 1 else 0,
		config = constants.SPRING_CONFIG,
	})

	local numParents = useMemo(function()
		return countParents(props.node)
	end, { props.node })

	local children = useMemo(function()
		local elements: { [string]: React.Node } = {}
		if props.node.children then
			for index, child in props.node.children do
				elements[child.label] = React.createElement(TreeNode, {
					layoutOrder = index,
					node = child,
				})
			end
		end
		return elements
	end, { props.node.children })

	local onMouseEnter = useCallback(function()
		setIsHovered(true)
	end, {})

	local onMouseLeave = useCallback(function()
		setIsHovered(false)
	end, {})

	local onActivated = useCallback(function()
		if props.onActivated then
			props.onActivated()
		end

		treeViewContext.activateNode(props.node)
	end, { props.onActivated, treeViewContext, props.node } :: { unknown })

	local onTogglePin = useCallback(function()
		if props.node.instance then
			pinning.togglePin(props.node.instance)
		end
	end, { pinning, props.node })

	local backgroundColor = useMemo(function(): Color3?
		if isSelected then
			return theme.selection
		else
			return theme.divider
		end
	end, { isSelected })

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		AutomaticSize = Enum.AutomaticSize.XY,
		ClipsDescendants = true,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Node = React.createElement("ImageButton", {
			LayoutOrder = 1,
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BorderSizePixel = 0,
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = styles.hover,

			[React.Event.MouseEnter] = onMouseEnter,
			[React.Event.MouseLeave] = onMouseLeave,
			[React.Event.Activated] = onActivated,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = theme.paddingSmall,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}),

			Corner = React.createElement("UICorner", {
				CornerRadius = theme.paddingSmall,
			}),

			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.paddingSmall,
				PaddingBottom = theme.paddingSmall,
				PaddingRight = theme.paddingSmall,
				PaddingLeft = theme.paddingSmall + UDim.new(0, theme.padding.Offset * numParents),
			}),

			Icon = React.createElement(Sprite, {
				image = icon,
				color = iconColor,
				layoutOrder = 1,
				size = UDim2.fromOffset(16, 16),
			}),

			Text = React.createElement("TextLabel", {
				LayoutOrder = 2,
				Text = props.node.label,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = theme.font,
				Size = UDim2.fromScale(1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme.text,
				TextSize = theme.textSize,
			}, {
				Flex = React.createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Shrink,
				}),
			}),

			Pin = React.createElement("ImageButton", {
				LayoutOrder = 3,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				[React.Event.Activated] = onTogglePin,
			}, {
				Icon = React.createElement(Sprite, {
					image = assets.Magnify, -- TODO: Use a new icon for pinning
					color = theme.text,
					size = UDim2.fromOffset(16, 16),
				}),
			}),

			Toggle = if #props.node.children > 0
				then React.createElement("Frame", {
					LayoutOrder = 4,
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.XY,
				}, {
					RotationWrapper = React.createElement("Frame", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.XY,
						Rotation = styles.expand:map(function(value)
							return 90 * value
						end),
					}, {
						Icon = React.createElement(Sprite, {
							image = assets.ChevronRight,
							color = theme.text,
							size = UDim2.fromOffset(16, 16),
						}),
					}),
				})
				else nil,
		}),

		Children = if isExpanded
			then React.createElement("Frame", {
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}, children)
			else nil,
	})
end

return TreeNode
