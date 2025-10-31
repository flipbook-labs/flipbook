local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")

local TreeNode = require("@root/TreeView/TreeNode")
local types = require("@root/TreeView/types")
local useTreeNodeFilter = require("@root/TreeView/useTreeNodeFilter")

local useSignalState = SignalsReact.useSignalState
local useEffect = React.useEffect

type TreeNodeStore = types.TreeNodeStore
type TreeNodeFilter = types.TreeNodeFilter

export type Props = {
	root: TreeNodeStore,
	filter: TreeNodeFilter?,
	layoutOrder: number?,
}

local function TreeView(props: Props)
	local rootNodeChildren = useSignalState(props.root.getChildren)

	useTreeNodeFilter(props.root, props.filter)

	useEffect(function()
		props.root.setSortOrder(function(a: TreeNodeStore, b: TreeNodeStore, scope: SignalsReact.scope)
			if a.getIcon(scope) ~= b.getIcon(scope) then
				-- Sort by type
				return a.getIcon(scope) < b.getIcon(scope)
			else
				-- Sort alphabetically
				return a.getName(scope):lower() < b.getName(scope):lower()
			end
		end)
	end, { props.root })

	local children: { [string]: React.Node } = {}
	for index, node in rootNodeChildren do
		children[node.id] = React.createElement(TreeNode, {
			node = node,
			LayoutOrder = index,
		})
	end

	return React.createElement(Foundation.View, {
		tag = "auto-xy col",
		LayoutOrder = props.layoutOrder,
	}, children)
end

return TreeView
