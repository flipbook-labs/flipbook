local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
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

local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useSignalState = SignalsReact.useSignalState
local useStorybooks = Storyteller.useStorybooks
local useOrphanedStoryModules = Storyteller.useOrphanedStoryModules

export type Props = {
	searchTerm: string?,
	onStoryChanged: ((storyModule: ModuleScript?, storybook: LoadedStorybook?) -> ())?,
	onShowErrorPage: ((unavailableStorybook: UnavailableStorybook) -> ())?,
	layoutOrder: number?,
}

local function StorybookTreeView(props: Props)
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })
	local unavailableStorybookByNodeId = useRef({} :: { [string]: UnavailableStorybook })
	local lastOpenedStory, setLastOpenedStory = useLastOpenedStory()
	local storybooks = useStorybooks()
	local orphanedStoryModules = useOrphanedStoryModules()
	local nodesByInstance = useRef({} :: { [Instance]: TreeNodeStore })

	local pinnedInstanceStore = useSignalState(PinnedInstanceStore.get)

	local rootNode = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("<root>")
		return node
	end, {})

	local pinned = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("Pinned")
		node.setIcon(TreeView.TreeNodeIcon.Pin)
		node.setIsExpanded(true)
		node.setIsVisible(false)
		node.parentTo(rootNode)

		return node
	end, { rootNode })

	local unavailableStorybooks = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("Unavailable Storybooks")
		node.setIcon(TreeView.TreeNodeIcon.Folder)
		node.setIsVisible(false)
		node.parentTo(rootNode)

		return node
	end, { rootNode })

	local unknownStories = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("Unknown Stories")
		node.setIcon(TreeView.TreeNodeIcon.Folder)
		node.setIsVisible(false)
		node.parentTo(rootNode)

		return node
	end, { rootNode })

	local pinnedChildren = useSignalState(pinned.getChildren)
	local pinnedNodes = useSignalState(rootNode.getPinnedDescendants)
	local prevPinnedNodes = usePrevious(pinnedNodes)

	local selectedNode = useSignalState(rootNode.getSelectedDescendants)[1]
	local prevSelectedNode: TreeNodeStore? = usePrevious(selectedNode)

	local filter = useCallback(function(node: TreeNodeStore)
		if not props.searchTerm or props.searchTerm == "" then
			return false
		end

		return node.getName(false):lower():match(props.searchTerm:lower()) == nil
	end, { props.searchTerm })

	-- There can be pinned paths that were never apart of the current DataModel,
	-- so only add the "Pinned" root if there are children to show
	useEffect(function()
		pinned.setIsVisible(#pinnedChildren > 0)
	end, { pinnedChildren } :: { unknown })

	-- This handles automatically moving a node under the Pinned node once the
	-- node's instance becomes pinned
	useEffect(function()
		if pinnedNodes ~= prevPinnedNodes then
			-- Put any previously pinned nodes back to the root
			if prevPinnedNodes then
				for _, node in prevPinnedNodes do
					if not node.getIsPinned(false) then
						node.parentTo(rootNode)
					end
				end
			end

			for _, node in pinnedNodes do
				node.parentTo(pinned)
			end
		end
	end, { pinnedNodes, prevPinnedNodes, pinned, rootNode } :: { unknown })

	-- Convert available storybooks into nodes
	useEffect(function()
		for _, storybook in storybooks.available do
			if nodesByInstance.current[storybook.source] then
				continue
			end

			local node = createTreeNodesForStorybook(storybook :: any)

			nodesByInstance.current[storybook.source] = node
			storybookByNodeId.current[node.id] = storybook :: any

			if pinnedInstanceStore.isPinned(storybook.source) then
				node.setIsPinned(true)
				node.parentTo(pinned)
			else
				node.parentTo(rootNode)
			end
		end
	end, { storybooks.available, pinnedInstanceStore.isPinned, pinned, rootNode } :: { unknown })

	-- Convert unavailable storybooks into nodes
	useEffect(function()
		unavailableStorybooks.setIsVisible(#storybooks.unavailable > 0)

		for _, unavailableStorybook in storybooks.unavailable do
			local source = unavailableStorybook.storybook.source

			if nodesByInstance.current[source] then
				continue
			end

			local node = TreeView.createTreeNodeStore()
			node.setName(unavailableStorybook.storybook.name)
			node.setIcon(TreeView.TreeNodeIcon.Alert)
			node.parentTo(unavailableStorybooks)

			nodesByInstance.current[source] = node
			unavailableStorybookByNodeId.current[node.id] = unavailableStorybook
		end
	end, { storybooks.unavailable, unavailableStorybooks })

	-- Convert orphaned stories into nodes
	useEffect(function()
		unknownStories.setIsVisible(#orphanedStoryModules > 0)

		for _, orphan in orphanedStoryModules do
			if nodesByInstance.current[orphan] then
				continue
			end

			local node = createTreeNodeForStoryModule(orphan)

			node.parentTo(unknownStories)
			nodesByInstance.current[orphan] = node
		end
	end, { orphanedStoryModules, unknownStories } :: { unknown })

	-- Handle the removal of any nodes when instances get removed
	useEffect(function()
		local instances: { Instance } = Sift.List.join(
			Sift.List.map(storybooks.available, function(storybook)
				return storybook.source
			end),
			Sift.List.map(storybooks.unavailable, function(unavailableStorybook)
				return unavailableStorybook.storybook.source
			end),
			orphanedStoryModules
		)

		for instance, node in nodesByInstance.current do
			if not table.find(instances, instance) then
				print("remove node for", instance)
				node.parentTo(nil)
				nodesByInstance.current[instance] = nil
			end
		end
	end, { storybooks.available, storybooks.unavailable, orphanedStoryModules } :: { unknown })

	-- Reopening the story from the previous session
	local wasLastStoryOpened = useRef(false)
	local descendants = useSignalState(rootNode.getDescendants)
	useEffect(
		function()
			if wasLastStoryOpened.current then
				return
			end

			if lastOpenedStory then
				local node = rootNode.findFirstDescendant(function(descendant)
					return descendant.getInstance(false) == lastOpenedStory
				end)

				if node then
					wasLastStoryOpened.current = true
					node.activate()
					node.expandUp()
				end
			end
		end,
		{
			lastOpenedStory,
			rootNode,
			-- This value isn't used in the effect body but is necessary so that
			-- the effect will run again if the last opened story has not but
			-- found yet
			descendants,
		} :: { unknown }
	)

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

							local storybook = if storybookNode then storybookByNodeId.current[storybookNode.id] else nil

							props.onStoryChanged(instance, storybook)
							setLastOpenedStory(instance)
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
		filter = filter,
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
