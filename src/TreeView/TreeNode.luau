local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactSpring = require("@pkg/ReactSpring")

local Sprite = require("@root/Common/Sprite")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local assets = require("@root/assets")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local types = require("@root/TreeView/types")
local useTheme = require("@root/Common/useTheme")
local useTreeNodeIcon = require("@root/TreeView/useTreeNodeIcon")

local useSpring = ReactSpring.useSpring :: any
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState
local useRef = React.useRef
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
	local theme = useTheme()
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

	local backgroundColor = useMemo(function(): Color3?
		if isSelected then
			return theme.selection
		else
			return theme.divider
		end
	end, { isSelected })

	local lastState: { current: Foundation.ControlState? } = useRef(nil)
	local onStateChanged = useCallback(function(newState: Foundation.ControlState)
		if newState == Foundation.Enums.ControlState.Hover then
			onMouseEnter()
		end

		if lastState.current == Foundation.Enums.ControlState.Hover then
			onMouseLeave()
		end

		lastState.current = newState
	end, { onMouseEnter, onMouseLeave })

	return React.createElement(Foundation.View, {
		tag = "auto-xy clip col",
		LayoutOrder = props.layoutOrder,
	}, {
		Node = React.createElement(Foundation.View, {
			tag = "auto-xy row gap-medium flex-fill radius-medium flex-between",
			padding = {
				top = UDim.new(0, tokens.Padding.Small),
				right = UDim.new(0, tokens.Padding.Large),
				bottom = UDim.new(0, tokens.Padding.Small),
				left = UDim.new(0, tokens.Padding.Small * numParents),
			},
			backgroundStyle = {
				Color3 = backgroundColor,
				Transparency = styles.hover,
			},
			onStateChanged = onStateChanged,
			onActivated = onActivated,
			LayoutOrder = nextLayoutOrder(),
		}, {
			Icon = React.createElement(Sprite, {
				image = icon,
				color = iconColor,
				layoutOrder = nextLayoutOrder(),
				size = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500),
			}),

			Text = React.createElement(Foundation.Text, {
				tag = "size-full-0 auto-y text-body-medium text-align-x-left shrink",
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
						Icon = React.createElement(Sprite, {
							image = assets.ChevronRight,
							color = theme.text,
							size = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400),
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
