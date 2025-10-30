local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")

local TreeNode = require("@root/TreeView/TreeNode")
local types = require("@root/TreeView/types")

local useSignalState = SignalsReact.useSignalState
local useCallback = React.useCallback
local useRef = React.useRef

type TreeNodeStore = types.TreeNodeStore

export type Props = {
	root: TreeNodeStore,
	layoutOrder: number?,
}

local function TreeView(props: Props)
	local rootNodeChildren = useSignalState(props.root.getChildren)
	local lastSelectedNode = useRef(nil :: TreeNodeStore?)

	local onNodeActivated = useCallback(function(node: TreeNodeStore)
		if node.getIsSelected(false) then
			if lastSelectedNode.current then
				lastSelectedNode.current.setIsSelected(false)
			end
			lastSelectedNode.current = node
		end
	end, {})

	local children: { [string]: React.Node } = {}
	for index, node in rootNodeChildren do
		children[node.getName(false)] = React.createElement(TreeNode, {
			node = node,
			onActivated = onNodeActivated,
			LayoutOrder = index,
		})
	end

	return React.createElement(Foundation.View, {
		tag = "auto-xy col",
		LayoutOrder = props.layoutOrder,
	}, children)
end

return TreeView
