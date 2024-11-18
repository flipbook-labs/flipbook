local React = require("@pkg/React")

local useTheme = require("@root/Common/useTheme")
local treeViewTypes = require("@root/TreeView/types")
local TreeNode = require("@root/TreeView/TreeNode")

local useCallback = React.useCallback
local useMemo = React.useMemo

type TreeNode = treeViewTypes.TreeNode
type Tree = treeViewTypes.Tree

export type Props = {
	roots: { TreeNode },
	expandedNodes: { TreeNode }?,
	onActivated: ((node: TreeNode) -> ())?,
	filter: ((node: TreeNode) -> boolean)?,
}

local function TreeView(props: Props)
	local theme = useTheme()

	local nodesById = useMemo(function() end, { props.roots })

	local leafNodes = useMemo(function() end, { props.roots })

	local onNodeActivated = useCallback(function(node: TreeNode)
		if props.onActivated then
			props.onActivated(node)
		end
	end, { props.onActivated })

	local children: { [string]: React.Node } = {}
	for index, node in props.roots do
		children[node.label] = React.createElement(TreeNode, {
			layoutOrder = index,
			node = node,
			onActivated = function()
				onNodeActivated(node)
			end,
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = theme.paddingSmall,
		}),
	}, children)
end

return TreeView
