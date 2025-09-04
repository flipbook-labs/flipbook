local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")
local TreeView = require("@root/TreeView")

local createTreeNodesForStorybook = require("@root/Storybook/createTreeNodesForStorybook")
local useLastOpenedStory = require("@root/Storybook/useLastOpenedStory")
local usePrevious = require("@root/Common/usePrevious")

type TreeNode = TreeView.TreeNode
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
	local treeViewContext = TreeView.useTreeViewContext()

	local selectedNode = treeViewContext.getSelectedNode()
	local prevSelectedNode = usePrevious(selectedNode)
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })
	local lastOpenedStory, setLastOpenedStory = useLastOpenedStory()

	useEffect(function()
		storybookByNodeId.current = {}
		local roots: { TreeNode } = {}
		for _, storybook in props.storybooks do
			-- FIXME: Need to cast each `storybook` variable to `any` to fix an
			-- issue where the ModuleLoader type is somehow not compareable to
			-- itself
			local root = createTreeNodesForStorybook(storybook :: any)
			table.insert(roots, root)
			storybookByNodeId.current[root.id] = storybook :: any
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
					selectedNode.icon == TreeView.TreeNodeIcon.Story
					and selectedNode.instance
					and selectedNode.instance:IsA("ModuleScript")
				then
					local ancestry = TreeView.getAncestry(selectedNode)
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

	return React.createElement(TreeView.TreeView, {
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
