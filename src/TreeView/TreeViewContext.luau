local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local createTreeNodesFromPartials = require("@root/TreeView/createTreeNodesFromPartials")
local types = require("@root/TreeView/types")

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode

local useCallback = React.useCallback
local useContext = React.useContext
local useState = React.useState

local function getAncestry(node: TreeNode): { TreeNode }
	local ancestry = {}
	local parent = node.parent
	while parent do
		table.insert(ancestry, parent)
		parent = parent.parent
	end
	return ancestry
end

type TreeViewContext = {
	setRoots: (nodes: { PartialTreeNode }) -> (),
	getRoots: () -> { TreeNode },
	activateNode: (node: TreeNode) -> (),
	isExpanded: (node: TreeNode) -> boolean,
	isSelected: (node: TreeNode) -> boolean,
}

local TreeViewContext = React.createContext(nil)

local function TreeNodeProvider(props: {
	children: React.Node,
})
	local nodes, setNodes = useState({
		roots = {} :: { TreeNode },
		leaves = {} :: { TreeNode },
	})

	local expandedNodes, setExpandedNodes = useState({} :: { TreeNode })
	local selectedNode, setSelectedNode = useState(nil :: TreeNode?)

	local expand = useCallback(function(node: TreeNode)
		setExpandedNodes(function(prev)
			-- If the parent node is not expanded then make sure to expand out
			-- the ancestors too
			local ancestry
			if node.parent and not table.find(prev, node.parent) then
				ancestry = getAncestry(node)
			end

			return Sift.List.join(prev, { node }, ancestry)
		end)
	end, {})

	local collapse = useCallback(function(node: TreeNode)
		setExpandedNodes(function(prev)
			local index = table.find(prev, node)
			if index then
				local new = table.clone(prev)
				table.remove(new, index)
				return new
			end
			return prev
		end)
	end, {})

	local setRoots = useCallback(function(partials: { PartialTreeNode })
		local newNodes = createTreeNodesFromPartials(partials)

		for _, node in newNodes.expandedByDefault do
			expand(node)
		end

		setNodes({
			roots = newNodes.roots,
			leaves = newNodes.leaves,
		})
	end, {})

	local getRoots = useCallback(function()
		return nodes.roots
	end, { nodes })

	-- local getLeaves = useCallback(function()
	-- 	return nodes.leaves
	-- end, { nodes })

	local isExpanded = useCallback(function(node: TreeNode): boolean
		return table.find(expandedNodes, node) ~= nil
	end, { expandedNodes })

	local isSelected = useCallback(function(node: TreeNode): boolean
		return selectedNode == node
	end, { selectedNode })

	local activateNode = useCallback(function(node: TreeNode)
		if isExpanded(node) then
			collapse(node)
		else
			expand(node)
		end

		if node ~= selectedNode then
			if table.find(nodes.leaves, node) then
				setSelectedNode(node)
			end
		else
			setSelectedNode(nil)
		end
	end, { nodes, selectedNode, isExpanded, expand, collapse } :: { unknown })

	local context: TreeViewContext = {
		setRoots = setRoots,
		getRoots = getRoots,
		activateNode = activateNode,
		isExpanded = isExpanded,
		isSelected = isSelected,
	}

	return React.createElement(TreeViewContext.Provider, {
		value = context,
	}, props.children)
end

local function use(): TreeViewContext
	local context = useContext(TreeViewContext)
	assert(context, "failed to use TreeViewContext, is `TreeViewContext.Provider` defined in the React hierarchy?`")
	return context
end

return {
	Provider = TreeNodeProvider,
	use = use,
}
