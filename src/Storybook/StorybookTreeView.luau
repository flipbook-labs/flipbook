local HttpService = game:GetService("HttpService")

local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")
local TreeView = require("@root/TreeView")

local createTreeNodesForStorybook = require("@root/Storybook/createTreeNodesForStorybook")
local useLastOpenedStory = require("@root/Storybook/useLastOpenedStory")
local usePinnedInstances = require("@root/TreeView/usePinnedInstances")
local usePrevious = require("@root/Common/usePrevious")

type TreeNode = TreeView.TreeNode
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local useEffect = React.useEffect
local useRef = React.useRef

export type Props = {
	searchTerm: string?,
	storybooks: {
		available: { LoadedStorybook },
		unavailable: { UnavailableStorybook },
	},
	onStoryChanged: ((storyModule: ModuleScript?, storybook: LoadedStorybook?) -> ())?,
	onShowErrorPage: ((unavailableStorybook: UnavailableStorybook) -> ())?,
	layoutOrder: number?,
}

local function StorybookTreeView(props: Props)
	local treeViewContext = TreeView.useTreeViewContext()

	local selectedNode = treeViewContext.getSelectedNode()
	local prevSelectedNode = usePrevious(selectedNode)
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })
	local unavailableStorybookByNodeId = useRef({} :: { [string]: UnavailableStorybook })
	local lastOpenedStory, setLastOpenedStory = useLastOpenedStory()
	local pinning = usePinnedInstances()

	useEffect(function()
		local roots: { TreeNode } = {}

		local pinnedInstances = pinning.getPinnedInstances()
		if #pinnedInstances > 0 then
			local pins: TreeNode = {
				id = HttpService:GenerateGUID(),
				label = "Starred",
				icon = "star",
				isExpanded = false,
				children = {},
			}

			for _, pinnedInstance in pinnedInstances do
				local node: { TreeNode }
				if pinnedInstance.instance then
					node = treeViewContext.getNodeByInstance(pinnedInstance.instance)
				end

				if not node then
					node = {
						id = HttpService:GenerateGUID(),
						label = `ERR: {pinnedInstance.path}`,
						icon = "folder", -- TODO: Use an error icon
						isExpanded = true,
						children = {},
					}
				end

				table.insert(pins.children, node)
			end

			table.insert(roots, pins)
		end

		for _, storybook in props.storybooks.available do
			-- FIXME: Need to cast each `storybook` variable to `any` to fix an
			-- issue where the ModuleLoader type is somehow not compareable to
			-- itself
			local root = createTreeNodesForStorybook(storybook :: any)
			table.insert(roots, root)
			storybookByNodeId.current[root.id] = storybook :: any
		end

		if #props.storybooks.unavailable > 0 then
			local unavailableStorybooks: TreeNode = {
				id = HttpService:GenerateGUID(),
				label = "Unavailable Storybooks",
				icon = "folder",
				isExpanded = false,
				children = {},
			}

			-- Luau FIXME: Without using `pairs` here Luau will get angry about
			-- the `unavailableStorybookByNodeId` assignment below
			for _, unavailableStorybook in pairs(props.storybooks.unavailable) do
				local root: TreeNode = {
					id = HttpService:GenerateGUID(),
					label = unavailableStorybook.storybook.name,
					icon = "alert",
					isExpanded = false,
					children = {},
				}
				table.insert(unavailableStorybooks.children, root)
				unavailableStorybookByNodeId.current[root.id] = unavailableStorybook
			end

			table.insert(roots, unavailableStorybooks)
		end

		treeViewContext.setRoots(roots)

		return function()
			treeViewContext.setRoots({})
		end
	end, { props.storybooks.available, props.storybooks.unavailable, treeViewContext.setRoots } :: { unknown })

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

	useEffect(
		function()
			if selectedNode ~= prevSelectedNode then
				if props.onStoryChanged then
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

				if props.onShowErrorPage then
					if selectedNode and selectedNode.icon == TreeView.TreeNodeIcon.Alert then
						local unavailableStorybook = unavailableStorybookByNodeId.current[selectedNode.id]
						if unavailableStorybook then
							props.onShowErrorPage(unavailableStorybook)
						end
					end
				end
			end
		end,
		{ props.onShowErrorPage, props.onStoryChanged, selectedNode, prevSelectedNode, setLastOpenedStory } :: { unknown }
	)

	return React.createElement(TreeView.TreeView, {
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
