local Selection = game:GetService("Selection")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")

local PinnedInstanceStore = require("@root/Storybook/PinnedInstanceStore")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local Types = require("@root/TreeView/types")
local useTreeNodeIcon = require("@root/TreeView/useTreeNodeIcon")

local Icon = Foundation.Icon
local IconName = Foundation.Enums.IconName
local IconSize = Foundation.Enums.IconSize
local IconVariant = Foundation.Enums.IconVariant
local Text = Foundation.Text
local View = Foundation.View
local useTokens = Foundation.Hooks.useTokens
local withCommonProps = Foundation.Utility.withCommonProps

local e = React.createElement
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState
local useRef = React.useRef

local useSignalState = SignalsReact.useSignalState

type TreeNode = Types.TreeNode

local function getParentCount(node: TreeNode): number
	local current = node
	local count = 0

	while current.parent do
		current = current.parent
		count += 1
	end

	return count
end

type TreeNodeProps = {
	node: TreeNode,
	onActivated: () -> ()?,
} & Foundation.CommonProps

local function TreeNode(props: TreeNodeProps)
	local treeView = TreeViewContext.use()
	local isExpanded = treeView.isExpanded(props.node)
	local isSelected = treeView.isSelected(props.node)
	local isContextMenuOpen, setIsContextMenuOpen = useState(false)
	local nodeRef = useRef(nil :: GuiObject?)

	local tokens = useTokens()
	local iconName, iconStyle = useTreeNodeIcon(props.node.icon)
	local pinnedInstanceStore = useSignalState(PinnedInstanceStore.get)
	local isPinned = if props.node.instance then pinnedInstanceStore.isPinned(props.node.instance) else false

	local children = useMemo(function()
		local elements: { [string]: React.ReactNode } = {}

		for index, childNode in props.node.children do
			elements[childNode.label] = e(TreeNode, {
				LayoutOrder = index,
				node = childNode,
			})
		end

		return elements
	end, { props.node.children })

	local parentCount = useMemo(function()
		return getParentCount(props.node) + 1
	end, { props.node })

	local onActivated = useCallback(function()
		if props.onActivated ~= nil then
			props.onActivated()
		end

		treeView.activateNode(props.node)
	end, { props.onActivated, treeView.activateNode, props.node } :: { any })

	local onSecondaryActivated = useCallback(function()
		if props.node.icon == Types.TreeNodeIcon.Storybook then
			setIsContextMenuOpen(true)
		end
	end, { props.node.icon })

	local onTogglePin = useCallback(function()
		if props.node.instance then
			if isPinned then
				pinnedInstanceStore.unpin(props.node.instance)
			else
				pinnedInstanceStore.pin(props.node.instance)
			end
		end
	end, { isPinned, pinnedInstanceStore.unpin, pinnedInstanceStore.pin, props.node.instance } :: { unknown })

	return e(
		View,
		withCommonProps(props, {
			tag = "auto-y col size-full-0",
		}),
		{
			Node = e(View, {
				LayoutOrder = 1,
				backgroundStyle = if isSelected then tokens.Color.ActionEmphasis.Background else nil,
				onActivated = onActivated,
				onSecondaryActivated = onSecondaryActivated,
				padding = {
					left = UDim.new(0, tokens.Padding.Medium * parentCount),
				},
				tag = "align-y-center auto-y gap-medium padding-right-medium padding-y-medium row size-full-0",
				ref = nodeRef,
			}, {
				Icon = e(Icon, {
					LayoutOrder = 1,
					name = iconName,
					size = IconSize.Small,
					style = iconStyle,
					variant = if isSelected then IconVariant.Filled else nil,
				}),

				Title = e(Text, {
					LayoutOrder = 2,
					Text = props.node.label,
					tag = {
						["auto-y shrink size-full-0 text-align-x-left text-label-medium text-truncate-end"] = true,
						["content-emphasis"] = isSelected,
					},
				}),

				Arrow = #props.node.children > 0 and e(Icon, {
					LayoutOrder = 3,
					name = if isExpanded then IconName.ChevronSmallUp else IconName.ChevronSmallDown,
					size = IconSize.XSmall,
				}),
			}),

			ContextMenu = if isContextMenuOpen
				then React.createElement(Foundation.Menu, {
					isOpen = true,
					size = Foundation.Enums.InputSize.Medium,
					items = {
						{
							id = "pin",
							text = if isPinned then "Unpin" else "Pin",
							onActivated = function()
								onTogglePin()
								setIsContextMenuOpen(false)
							end,
						},
						{
							id = "select-in-explorer",
							text = "Select in Explorer",
							onActivated = function()
								Selection:Set({ props.node.instance })
								setIsContextMenuOpen(false)
							end,
						},
					},
					onPressedOutside = function()
						setIsContextMenuOpen(false)
					end,
					anchorRef = nodeRef,
				})
				else nil,

			Children = isExpanded and e(View, {
				LayoutOrder = 2,
				tag = "auto-xy col",
			}, children),
		}
	)
end

return React.memo(TreeNode)
