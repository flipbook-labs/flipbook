local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local TreeNode = require("@root/TreeView/TreeNode")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local types = require("@root/TreeView/types")

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode
type Tree = types.Tree

local function TreeView(props: {
	layoutOrder: number?,
})
	local treeViewContext = TreeViewContext.use()

	local children: { [string]: React.Node } = {}
	for index, node in treeViewContext.getRoots() do
		children[node.label] = React.createElement(TreeNode, {
			layoutOrder = index,
			node = node,
		})
	end

	return React.createElement(Foundation.View, {
		tag = "auto-xy col",
		LayoutOrder = props.layoutOrder,
	}, children)
end

return TreeView
