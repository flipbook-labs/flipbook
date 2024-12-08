local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView/TreeView")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local createTreeNodesForStorybook = require("./createTreeNodesForStorybook")
local getAncestry = require("@root/TreeView/getAncestry")
local treeViewTypes = require("@root/TreeView/types")

type TreeNode = treeViewTypes.TreeNode
type LoadedStorybook = Storyteller.LoadedStorybook

local useEffect = React.useEffect
local useRef = React.useRef

export type Props = {
	searchTerm: string?,
	storybooks: { LoadedStorybook },
	onStorySelected: ((storyModule: ModuleScript, storybook: LoadedStorybook) -> ())?,
	layoutOrder: number?,
}

local function StorybookTreeView(props: Props)
	local treeViewContext = TreeViewContext.use()
	local selectedNode = treeViewContext.getSelectedNode()
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })

	useEffect(function()
		storybookByNodeId.current = {}
		local roots: { TreeNode } = {}
		for _, storybook in props.storybooks do
			local root = createTreeNodesForStorybook(storybook)
			table.insert(roots, root)
			storybookByNodeId.current[root.id] = storybook
		end
		treeViewContext.setRoots(roots)

		return function()
			treeViewContext.setRoots({})
		end
	end, { props.storybooks, treeViewContext.setRoots } :: { unknown })

	useEffect(function()
		treeViewContext.search(props.searchTerm)
	end, { props.searchTerm, treeViewContext.search } :: { unknown })

	useEffect(function()
		if
			props.onStorySelected
			and selectedNode
			and selectedNode.icon == "story"
			and selectedNode.instance
			and selectedNode.instance:IsA("ModuleScript")
		then
			local ancestry = getAncestry(selectedNode)
			local root = ancestry[#ancestry]
			local storybook = storybookByNodeId.current[root.id]

			if storybook then
				props.onStorySelected(selectedNode.instance, storybook)
			end
		end
	end, { props.onStorySelected, selectedNode } :: { unknown })

	return React.createElement(TreeView, {
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
