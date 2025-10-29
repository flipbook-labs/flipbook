local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")
local Storyteller = require("@pkg/Storyteller")
local TreeView = require("@root/TreeView")

local PinnedInstanceStore = require("@root/Storybook/PinnedInstanceStore")
local createTreeNodeForStoryModule = require("@root/Storybook/createTreeNodeForStoryModule")
local createTreeNodesForStorybook = require("@root/Storybook/createTreeNodesForStorybook")
local useLastOpenedStory = require("@root/Storybook/useLastOpenedStory")
local usePrevious = require("@root/Common/usePrevious")

type TreeNodeStore = TreeView.TreeNodeStore
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook
type LoadedStory<T> = Storyteller.LoadedStory<T>

local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useSignalState = SignalsReact.useSignalState

export type Props = {
	searchTerm: string?,
	storybooks: {
		available: { LoadedStorybook },
		unavailable: { UnavailableStorybook },
	},
	orphanedStoryModules: { ModuleScript }?,
	onStoryChanged: ((storyModule: ModuleScript?, storybook: LoadedStorybook?) -> ())?,
	onShowErrorPage: ((unavailableStorybook: UnavailableStorybook) -> ())?,
	layoutOrder: number?,
}

local function StorybookTreeView(props: Props)
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })
	local unavailableStorybookByNodeId = useRef({} :: { [string]: UnavailableStorybook })
	local lastOpenedStory, setLastOpenedStory = useLastOpenedStory()

	local pinnedInstanceStore = useSignalState(PinnedInstanceStore.get)
	local pinnedInstances = useSignalState(pinnedInstanceStore.getPinnedInstances)

	local rootNode = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("<root>")
		return node
	end, {})

	local pins = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("Pinned")
		node.setIcon(TreeView.TreeNodeIcon.Pin)
		node.setIsExpanded(true)
		node.setIsVisible(false)
		node.parentTo(rootNode)

		return node
	end, { rootNode })

	local pinnedChildren = useSignalState(pins.getChildren)

	-- There can be pinned paths that were never apart of the current DataModel,
	-- so only add the "Pinned" root if there are children to show
	useEffect(function()
		pins.setIsVisible(#pinnedChildren > 0)
	end, { pinnedChildren })

	local selectedNode = useSignalState(rootNode.getSelectedDescendants)[1]
	local prevSelectedNode = usePrevious(selectedNode)

	useEffect(
		function()
			for _, storybook in props.storybooks.available do
				local node = createTreeNodesForStorybook(storybook :: any)
				storybookByNodeId.current[node.id] = storybook :: any

				if pinnedInstanceStore.isPinned(storybook.source) then
					node.parentTo(pins)
				else
					node.parentTo(rootNode)
				end
			end

			if #props.storybooks.unavailable > 0 then
				local unavailableStorybooks = TreeView.createTreeNodeStore()
				unavailableStorybooks.setName("Unavailable Storybooks")
				unavailableStorybooks.setIcon(TreeView.TreeNodeIcon.Folder)

				for _, unavailableStorybook in props.storybooks.unavailable do
					local node = TreeView.createTreeNodeStore()
					node.setName(unavailableStorybook.storybook.name)
					node.setIcon(TreeView.TreeNodeIcon.Alert)
					node.parentTo(unavailableStorybooks)

					unavailableStorybookByNodeId.current[rootNode.id] = unavailableStorybook
				end

				unavailableStorybooks.parentTo(rootNode)
			end

			if props.orphanedStoryModules and #props.orphanedStoryModules > 0 then
				local orphanedStories = TreeView.createTreeNodeStore()
				orphanedStories.setName("Unknown Stories")
				orphanedStories.setIcon(TreeView.TreeNodeIcon.Folder)

				for _, orphan in props.orphanedStoryModules do
					local node = createTreeNodeForStoryModule(orphan)
					node.parentTo(orphanedStories)
				end

				orphanedStories.parentTo(rootNode)
			end
		end,
		{
			props.storybooks.available,
			props.storybooks.unavailable,
			pinnedInstanceStore.isPinned,
			pinnedInstances,
			rootNode,
			pins,
		} :: { unknown }
	)

	-- FIXME: Add simple filtering by string
	-- useEffect(function()
	-- 	rootNode.setFilter(props.searchTerm)
	-- end, { props.searchTerm, rootNode } :: { unknown })

	local wasLastStoryOpened = useRef(false)
	useEffect(function()
		if wasLastStoryOpened.current then
			return
		end

		if lastOpenedStory then
			local node: TreeNodeStore?

			for _, descendant in rootNode.getDescendants(false) do
				if descendant.getInstance(false) == lastOpenedStory then
					node = descendant
					break
				end
			end

			if node then
				wasLastStoryOpened.current = true
				node.activate()
			end
		end
	end, { lastOpenedStory, rootNode } :: { unknown })

	useEffect(
		function()
			if selectedNode ~= prevSelectedNode then
				if props.onStoryChanged then
					if selectedNode then
						local icon = selectedNode.getIcon(false)
						local instance = selectedNode.getInstance(false)

						if icon == TreeView.TreeNodeIcon.Story and instance and instance:IsA("ModuleScript") then
							local storybookNode = selectedNode.findFirstAncestor(function(ancestor)
								return ancestor.getIcon(false) == TreeView.TreeNodeIcon.Storybook
							end)

							if storybookNode then
								local storybook = storybookByNodeId.current[storybookNode.id]

								props.onStoryChanged(instance, storybook)
								setLastOpenedStory(instance)
							end
						end
					else
						props.onStoryChanged(nil, nil)
					end
				end

				if props.onShowErrorPage then
					if selectedNode and selectedNode.getIcon(false) == TreeView.TreeNodeIcon.Alert then
						local unavailableStorybook = unavailableStorybookByNodeId.current[selectedNode.id]
						if unavailableStorybook then
							props.onShowErrorPage(unavailableStorybook)
						end
					end
				end
			end
		end,
		{
			props.onShowErrorPage,
			props.onStoryChanged,
			selectedNode,
			prevSelectedNode,
			setLastOpenedStory,
		} :: { unknown }
	)

	return React.createElement(TreeView.TreeView, {
		root = rootNode,
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
