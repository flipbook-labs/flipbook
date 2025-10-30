local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")

local TreeNode = require("@root/TreeView/TreeNode")
local types = require("@root/TreeView/types")

local useSignalState = SignalsReact.useSignalState
local useCallback = React.useCallback
local useEffect = React.useEffect
local useRef = React.useRef

type TreeNodeStore = types.TreeNodeStore
type TreeNodeFilter = (node: TreeNodeStore) -> boolean

local function useTreeNodeFilter(root: TreeNodeStore, filter: TreeNodeFilter?)
	local leaves = useSignalState(root.getLeafNodes)

	useEffect(function()
		if filter then
			-- Resetting the filtered state to do it all over again for the new
			-- filter function
			root.setIsFiltered(false)
			for _, descendant in root.getDescendants(false) do
				descendant.setIsFiltered(false)
			end

			local included = {}
			for _, leaf in leaves do
				if filter(leaf) then
					print("filtering", leaf.getName(false))
					leaf.setIsFiltered(true)

					local parent = leaf.getParent(false)
					while parent do
						-- If this parent was deemed to be included that means
						-- at least one descendant didn't match the filter, so
						-- we have to make sure we keep the connection up to the
						-- root
						if included[parent] then
							break
						end

						-- We've reached a node that isn't filtered, so all
						-- nodes above this one must also not be filtered. We
						-- stop here and go on to the next leaf node
						if filter(parent) == false then
							for _, ancestor in parent.getAncestors(false) do
								included[ancestor] = true
							end
							break
						end

						print("filtering", parent.getName(false))
						parent.setIsFiltered(true)
						parent = parent.getParent(false)
					end
				end
			end
		end
	end, { filter, leaves } :: { unknown })
end

export type Props = {
	root: TreeNodeStore,
	filter: TreeNodeFilter?,
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

	useTreeNodeFilter(props.root, props.filter)

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
