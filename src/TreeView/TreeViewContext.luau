local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local createTreeNodesFromPartials = require("@root/TreeView/createTreeNodesFromPartials")
local getAncestry = require("@root/TreeView/getAncestry")
local reduceTree = require("@root/TreeView/reduceTree")
local types = require("@root/TreeView/types")

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode

local useCallback = React.useCallback
local useContext = React.useContext
local useMemo = React.useMemo
local useState = React.useState

type TreeViewContext = {
	setRoots: (nodes: { PartialTreeNode | TreeNode }) -> (),
	getRoots: () -> { TreeNode },
	getNodeById: (nodeId: string) -> TreeNode?,
	getSelectedNode: () -> TreeNode?,
	activateNode: (node: TreeNode) -> (),
	isExpanded: (node: TreeNode) -> boolean,
	isSelected: (node: TreeNode) -> boolean,
	search: (searchTerm: string?) -> (),
}

local TreeViewContext = React.createContext(nil)

local function TreeNodeProvider(props: {
	children: React.Node,
})
	local nodes, setNodes = useState({
		roots = {} :: { TreeNode },
		leaves = {} :: { TreeNode },
		byId = {} :: { [string]: TreeNode },
	})

	local expandedNodes, setExpandedNodes = useState({} :: { TreeNode })
	local selectedNode, setSelectedNode = useState(nil :: TreeNode?)
	local searchTerm: string?, setSearchTerm = useState(nil :: string?)

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

	local filteredRoots = useMemo(function()
		if searchTerm then
			return reduceTree(nodes.roots, function(node)
				return node.label:lower():match(searchTerm:lower()) ~= nil
			end)
		else
			return nodes.roots
		end
	end, { nodes.roots, searchTerm } :: { unknown })

	local search = useCallback(function(newSearchTerm: string?)
		if newSearchTerm ~= "" then
			setSearchTerm(newSearchTerm)
		else
			setSearchTerm(nil)
		end
	end, {})

	local setRoots = useCallback(function(partials: { TreeNode | PartialTreeNode })
		local newNodes = createTreeNodesFromPartials(partials)

		for _, node in newNodes.expandedByDefault do
			expand(node)
		end

		setNodes({
			roots = newNodes.roots,
			leaves = newNodes.leaves,
			byId = newNodes.byId,
		})
	end, {})

	local getRoots = useCallback(function()
		return filteredRoots
	end, { filteredRoots })

	local getNodeById = useCallback(function(nodeId: string)
		return nodes.byId[nodeId]
	end, { nodes.byId })

	local getSelectedNode = useCallback(function()
		return selectedNode
	end, { selectedNode })

	local isExpanded = useCallback(function(node: TreeNode): boolean
		if searchTerm then
			return true
		else
			return table.find(expandedNodes, node) ~= nil
		end
	end, { expandedNodes, searchTerm } :: { unknown })

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
		getNodeById = getNodeById,
		getSelectedNode = getSelectedNode,
		activateNode = activateNode,
		isExpanded = isExpanded,
		isSelected = isSelected,
		search = search,
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
