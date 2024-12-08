local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView/TreeView")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local createTreeNodesForStorybook = require("@root/Storybook/createTreeNodesForStorybook")
local getAncestry = require("@root/TreeView/getAncestry")
local treeViewTypes = require("@root/TreeView/types")
local useLastOpenedStory = require("@root/Storybook/useLastOpenedStory")
local usePrevious = require("@root/Common/usePrevious")

type TreeNode = treeViewTypes.TreeNode
type LoadedStorybook = Storyteller.LoadedStorybook

local useEffect = React.useEffect
local useRef = React.useRef

export type Props = {
	searchTerm: string?,
	storybooks: { LoadedStorybook },
	onStoryChanged: ((storyModule: ModuleScript?, storybook: LoadedStorybook?) -> ())?,
	layoutOrder: number?,
}

local function StorybookTreeView(props: Props)
	local treeViewContext = TreeViewContext.use()

	local selectedNode = treeViewContext.getSelectedNode()
	local prevSelectedNode = usePrevious(selectedNode)
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })
	local lastOpenedStory, setLastOpenedStory = useLastOpenedStory()

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

	local wasLastStoryOpened = useRef(false)
	useEffect(function()
		if wasLastStoryOpened.current then
			return
		end

		if lastOpenedStory then
			local node = treeViewContext.getNodeByInstance(lastOpenedStory)

			if node then
				wasLastStoryOpened.current = true
				treeViewContext.activateNode(node)
			end
		end
	end, { lastOpenedStory, treeViewContext.getNodeByInstance, treeViewContext.activateNode } :: { unknown })

	useEffect(function()
		if props.onStoryChanged and selectedNode ~= prevSelectedNode then
			if selectedNode then
				if
					selectedNode.icon == "story"
					and selectedNode.instance
					and selectedNode.instance:IsA("ModuleScript")
				then
					local ancestry = getAncestry(selectedNode)
					local root = ancestry[#ancestry]
					local storybook = storybookByNodeId.current[root.id]

					if storybook then
						props.onStoryChanged(selectedNode.instance, storybook)
						setLastOpenedStory(selectedNode.instance)
					end
				end
			else
				props.onStoryChanged(nil, nil)
			end
		end
	end, { props.onStoryChanged, selectedNode, prevSelectedNode, setLastOpenedStory } :: { unknown })

	return React.createElement(TreeView, {
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
