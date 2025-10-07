local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)

local TreeNode = require(script.Parent.TreeNode)
local TreeViewContext = require(script.Parent.TreeViewContext)
local types = require(script.Parent.types)

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
			LayoutOrder = index,
			node = node,
		})
	end

	return React.createElement(Foundation.View, {
		tag = "auto-xy col",
		LayoutOrder = props.layoutOrder,
	}, children)
end

return TreeView
