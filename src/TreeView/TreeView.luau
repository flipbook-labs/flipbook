local React = require("@pkg/React")

local TreeNode = require("@root/TreeView/TreeNode")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local types = require("@root/TreeView/types")

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode
type Tree = types.Tree

local function TreeView(props: {
	LayoutOrder: number?,
})
	local treeViewContext = TreeViewContext.use()

	local children: { [string]: React.Node } = {}
	for index, node in treeViewContext.getRoots() do
		children[node.label] = React.createElement(TreeNode, {
			layoutOrder = index,
			node = node,
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = props.LayoutOrder,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}, children)
end

return TreeView
