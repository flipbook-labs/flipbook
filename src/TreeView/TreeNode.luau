local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactSpring = require("@pkg/ReactSpring")

local TreeViewContext = require("@root/TreeView/TreeViewContext")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local types = require("@root/TreeView/types")
local useTreeNodeIcon = require("@root/TreeView/useTreeNodeIcon")

local useSpring = ReactSpring.useSpring :: any
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState
local useTokens = Foundation.Hooks.useTokens

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
	local tokens = useTokens()
	local icon, iconColor = useTreeNodeIcon(props.node.icon)
	local isHovered, setIsHovered = useState(false)
	local treeViewContext = TreeViewContext.use()
	local isExpanded = treeViewContext.isExpanded(props.node)
	local isSelected = treeViewContext.isSelected(props.node)

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

	local onActivated = useCallback(function()
		if props.onActivated then
			props.onActivated()
		end

		treeViewContext.activateNode(props.node)
	end, { props.onActivated, treeViewContext, props.node } :: { unknown })

	local onStateChanged = useCallback(function(newState: Foundation.ControlState)
		setIsHovered(newState == Foundation.Enums.ControlState.Hover)
	end, {})

	return React.createElement(Foundation.View, {
		tag = "auto-xy clip col",
		LayoutOrder = props.layoutOrder,
	}, {
		Node = React.createElement(Foundation.View, {
			tag = "auto-xy row gap-medium flex-fill radius-medium flex-between padding-y-small",
			padding = {
				right = UDim.new(0, tokens.Padding.Large),
				left = UDim.new(0, tokens.Padding.Medium * numParents),
			},
			backgroundStyle = if isSelected then tokens.Color.Extended.Purple.Purple_800 else nil,
			onStateChanged = onStateChanged,
			onActivated = onActivated,
			LayoutOrder = nextLayoutOrder(),
		}, {
			Icon = React.createElement(Foundation.Icon, {
				name = icon,
				style = iconColor,
				size = Foundation.Enums.IconSize.Small,
				LayoutOrder = nextLayoutOrder(),
			}),

			Text = React.createElement(Foundation.Text, {
				tag = "size-full-0 auto-y text-label-medium text-align-x-left shrink",
				Text = props.node.label,
				LayoutOrder = nextLayoutOrder(),
			}),

			Toggle = if #props.node.children > 0
				then React.createElement(Foundation.View, {
					tag = "auto-xy",
					LayoutOrder = nextLayoutOrder(),
				}, {
					RotationWrapper = React.createElement(Foundation.View, {
						tag = "auto-xy",
						Rotation = styles.expand:map(function(value)
							return 90 * value
						end),
					}, {
						Icon = React.createElement(Foundation.Icon, {
							name = Foundation.Enums.IconName.ChevronLargeRight,
							style = tokens.Color.Extended.White.White_50,
							size = Foundation.Enums.IconSize.Small,
						}),
					}),
				})
				else nil,
		}),

		Children = if isExpanded
			then React.createElement(Foundation.View, {
				tag = "auto-xy col",
				LayoutOrder = nextLayoutOrder(),
			}, children)
			else nil,
	})
end

return TreeNode
