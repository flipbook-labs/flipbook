local React = require("@pkg/React")

local types = require("@root/TreeView/types")
local TreeNode = require("@root/TreeView/TreeNode")
local createTreeNodesFromPartials = require("@root/TreeView/createTreeNodesFromPartials")

local useCallback = React.useCallback
local useMemo = React.useMemo

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode
type Tree = types.Tree

export type Props = {
	roots: { PartialTreeNode },
	expandedNodes: { TreeNode }?,
	onActivated: ((node: TreeNode) -> ())?,
	filter: ((node: TreeNode) -> boolean)?,
}

local function TreeView(props: Props)
	local roots = useMemo(function(): { TreeNode }
		return createTreeNodesFromPartials(props.roots)
	end, { props.roots })

	local onNodeActivated = useCallback(function(node: TreeNode)
		if props.onActivated then
			props.onActivated(node)
		end
	end, { props.onActivated })

	local children: { [string]: React.Node } = {}
	for index, node in roots do
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
		}),
	}, children)
end

return TreeView
