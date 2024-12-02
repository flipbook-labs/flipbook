local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView/TreeView")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local creaTreeNodesForStorybook = require("@root/TreeView/creaTreeNodesForStorybook")
local treeViewTypes = require("@root/TreeView/types")

type TreeNode = treeViewTypes.TreeNode
type LoadedStorybook = Storyteller.LoadedStorybook

local useEffect = React.useEffect

export type Props = {
	storybooks: { LoadedStorybook },
	layoutOrder: number?,
}

local function StorybookTreeView(props: Props)
	local treeViewContext = TreeViewContext.use()

	useEffect(function()
		local roots: { TreeNode } = {}
		for _, storybook in props.storybooks do
			local nodes = creaTreeNodesForStorybook(storybook)
			table.insert(roots, nodes.root)
		end
		treeViewContext.setRoots(roots)
	end, { props.storybooks })

	return React.createElement(TreeView, {
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
