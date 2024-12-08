local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView/TreeView")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local createTreeNodesForStorybook = require("./createTreeNodesForStorybook")
local treeViewTypes = require("@root/TreeView/types")

type TreeNode = treeViewTypes.TreeNode
type LoadedStorybook = Storyteller.LoadedStorybook

local useEffect = React.useEffect

export type Props = {
	searchTerm: string?,
	storybooks: { LoadedStorybook },
	onStorySelected: ((storyModule: ModuleScript) -> ())?,
	layoutOrder: number?,
}

local function StorybookTreeView(props: Props)
	local treeViewContext = TreeViewContext.use()
	local selectedNode = treeViewContext.getSelectedNode()

	useEffect(function()
		local roots: { TreeNode } = {}
		for _, storybook in props.storybooks do
			local nodes = createTreeNodesForStorybook(storybook)
			table.insert(roots, nodes.root)
		end
		treeViewContext.setRoots(roots)

		return function()
			treeViewContext.setRoots({})
		end
	end, { props.storybooks, treeViewContext } :: { unknown })

	useEffect(function()
		treeViewContext.search(props.searchTerm)
	end, { props.searchTerm, treeViewContext } :: { unknown })

	useEffect(function()
		if
			props.onStorySelected
			and selectedNode
			and selectedNode.icon == "story"
			and selectedNode.instance
			and selectedNode.instance:IsA("ModuleScript")
		then
			props.onStorySelected(selectedNode.instance)
		end
	end, { props.onStorySelected, selectedNode } :: { unknown })

	return React.createElement(TreeView, {
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
