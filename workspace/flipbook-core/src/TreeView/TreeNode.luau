local Selection = game:GetService("Selection")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")

local PinnedInstanceStore = require("@root/Storybook/PinnedInstanceStore")
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

type TreeNodeStore = Types.TreeNodeStore

type TreeNodeProps = {
	node: TreeNodeStore,
	onActivated: () -> ()?,
} & Foundation.CommonProps

local function TreeNode(props: TreeNodeProps)
	local ancestors = useSignalState(props.node.getAncestors)
	local icon = useSignalState(props.node.getIcon)
	local instance = useSignalState(props.node.getInstance)
	local isExpanded = useSignalState(props.node.getIsExpanded)
	local isSelected = useSignalState(props.node.getIsSelected)
	local isVisible = useSignalState(props.node.getIsVisible)
	local name = useSignalState(props.node.getName)
	local nodeChildren = useSignalState(props.node.getChildren)
	local iconName, iconStyle = useTreeNodeIcon(icon :: Types.TreeNodeIcon)

	local isContextMenuOpen, setIsContextMenuOpen = useState(false)
	local ref = useRef(nil :: GuiObject?)

	local tokens = useTokens()
	local pinnedInstanceStore = useSignalState(PinnedInstanceStore.get)
	local isPinned = if instance then pinnedInstanceStore.isPinned(instance) else false

	local children = useMemo(function()
		-- do sorting here
		local elements: { [string]: React.ReactNode } = {}

		local sortedNodes = table.clone(nodeChildren)
		table.sort(sortedNodes, function(a, b)
			if a.getIcon(false) ~= b.getIcon(false) then
				-- Sort by type
				return a.getIcon(false) < b.getIcon(false)
			else
				-- Sort alphabetically
				return a.getName(false):lower() < b.getName(false):lower()
			end
		end)

		for index, childNode in sortedNodes do
			elements[childNode.getName(false)] = e(TreeNode, {
				LayoutOrder = index,
				node = childNode,
			})
		end

		return elements
	end, { nodeChildren })

	local onActivated = useCallback(function()
		if props.onActivated ~= nil then
			props.onActivated()
		end

		props.node.activate()
	end, { props.onActivated, props.node } :: { unknown })

	local onSecondaryActivated = useCallback(function()
		setIsContextMenuOpen(true)
	end, {})

	local onTogglePin = useCallback(function()
		if instance then
			if isPinned then
				pinnedInstanceStore.unpin(instance)
			else
				pinnedInstanceStore.pin(instance)
			end
		end
	end, { isPinned, pinnedInstanceStore.unpin, pinnedInstanceStore.pin, instance } :: { unknown })

	local contextMenuItems = useMemo(function()
		local items: { Foundation.MenuItem } = {}

		if icon == Types.TreeNodeIcon.Storybook then
			table.insert(items, {
				id = "pin",
				text = if isPinned then "Unpin" else "Pin",
				onActivated = function()
					onTogglePin()
					setIsContextMenuOpen(false)
				end,
			})
		end

		table.insert(items, {
			id = "select-in-explorer",
			text = "Select in Explorer",
			onActivated = function()
				Selection:Set({ instance })
				setIsContextMenuOpen(false)
			end,
		})

		if #nodeChildren > 0 then
			table.insert(items, {
				id = "expand-all",
				text = "Expand all",
				onActivated = function()
					props.node.expandDown()
					setIsContextMenuOpen(false)
				end,
			})
			table.insert(items, {
				id = "collapse-all",
				text = "Collapse all",
				onActivated = function()
					props.node.collapseDown()
					setIsContextMenuOpen(false)
				end,
			})
		end

		return items
	end, { isPinned, icon, nodeChildren, props.node } :: { unknown })

	if not isVisible then
		return nil
	end

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
					left = UDim.new(0, tokens.Padding.Medium * #ancestors),
				},
				tag = "align-y-center auto-y gap-medium padding-right-medium padding-y-medium row size-full-0",
				ref = ref,
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
					Text = name,
					tag = {
						["auto-y shrink size-full-0 text-align-x-left text-label-medium text-truncate-end"] = true,
						["content-emphasis"] = isSelected,
					},
				}),

				Arrow = #nodeChildren > 0 and e(Icon, {
					LayoutOrder = 3,
					name = if isExpanded then IconName.ChevronSmallUp else IconName.ChevronSmallDown,
					size = IconSize.XSmall,
				}),
			}),

			ContextMenu = if isContextMenuOpen
				then React.createElement(Foundation.Menu, {
					isOpen = true,
					size = Foundation.Enums.InputSize.Medium,
					items = contextMenuItems,
					onPressedOutside = function()
						setIsContextMenuOpen(false)
					end,
					anchorRef = ref,
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
