local Charm = require("@pkg/Charm")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")
local TreeView = require("@root/TreeView")

local PinnedInstanceStore = require("@root/Storybook/PinnedInstanceStore")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createTreeNodeForStoryModule = require("@root/Storybook/createTreeNodeForStoryModule")
local createTreeNodesForStorybook = require("@root/Storybook/createTreeNodesForStorybook")
local types = require("@root/Storybook/types")
local useLastOpenedStory = require("@root/Storybook/useLastOpenedStory")
local usePrevious = require("@root/Common/usePrevious")

type TreeNodeStore = TreeView.TreeNodeStore
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook
type StoryModuleSnapshot = types.StoryModuleSnapshot
type StoryModuleTarget = types.StoryModuleTarget

local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useSignalState = ReactCharm.useSignalState
local useStorybooks = Storyteller.useStorybooks
local useStoryModuleSnapshots = Storyteller.useStoryModuleSnapshots
local useOrphanedStoryModules = Storyteller.useOrphanedStoryModules

export type Props = {
	searchTerm: string?,
	onStoryChanged: ((storyModule: ModuleScript?, storybook: LoadedStorybook?, storyId: string?) -> ())?,
	onShowErrorPage: ((unavailableStorybook: UnavailableStorybook) -> ())?,
	layoutOrder: number?,
}

local function getSnapshotSignature(snapshot: StoryModuleSnapshot): string
	local parts = { snapshot.name }
	for _, story in snapshot.stories do
		table.insert(parts, story.id)
		table.insert(parts, story.name)
	end
	return table.concat(parts, "\0")
end

local function getSelectedStoryNode(node: TreeNodeStore): TreeNodeStore?
	if node.getIsSelected() then
		return node
	end
	return node.findFirstDescendant(function(descendant)
		return descendant.getIsSelected()
	end)
end

local function findStoryNode(node: TreeNodeStore, storyId: string?): TreeNodeStore?
	if node.getIcon() == TreeView.TreeNodeIcon.Story then
		return node
	end

	local firstStoryNode
	for _, child in node.getChildren() do
		if child.getIcon() == TreeView.TreeNodeIcon.Story then
			firstStoryNode = firstStoryNode or child
			if storyId ~= nil and child.getStoryId() == storyId then
				return child
			end
		end
	end
	-- A persisted ID can become stale after a Story is renamed or removed.
	-- Keep the module selectable by falling back to its first current Story.
	return firstStoryNode
end

local function indexStoryModuleNodes(
	root: TreeNodeStore,
	storyModules: { ModuleScript }
): { [ModuleScript]: TreeNodeStore }
	local expectedModules = {} :: { [ModuleScript]: boolean }
	for _, storyModule in storyModules do
		expectedModules[storyModule] = true
	end

	local nodes = {}
	for _, node in root.getDescendants() do
		local instance = node.getInstance()
		if instance and instance:IsA("ModuleScript") and expectedModules[instance] then
			local parent = node.getParent()
			if not parent or parent.getInstance() ~= instance then
				nodes[instance] = node
			end
		end
	end
	return nodes
end

local function getStorybookTreeSignature(storybook: LoadedStorybook, storyModules: { ModuleScript }): { unknown }
	local parts = { storybook.name } :: { unknown }
	for _, storyRoot in storybook.storyRoots do
		table.insert(parts, storyRoot)
		table.insert(parts, storyRoot.Name)
	end
	for _, storyModule in storyModules do
		table.insert(parts, storyModule)
		table.insert(parts, storyModule.Name)
		local ancestor = storyModule.Parent
		while ancestor do
			table.insert(parts, ancestor)
			table.insert(parts, ancestor.Name)
			if table.find(storybook.storyRoots, ancestor) then
				break
			end
			ancestor = ancestor.Parent
		end
	end
	return parts
end

local function areSameStorybookTreeSignatures(previous: { unknown }?, current: { unknown }): boolean
	if not previous or #previous ~= #current then
		return false
	end
	for index, value in previous do
		if value ~= current[index] then
			return false
		end
	end
	return true
end

local function findStoryModuleNode(root: TreeNodeStore, storyModule: ModuleScript): TreeNodeStore?
	return root.findFirstDescendant(function(descendant)
		if descendant.getInstance() ~= storyModule then
			return false
		end
		local parent = descendant.getParent()
		return not parent or parent.getInstance() ~= storyModule
	end)
end

local function StorybookTreeView(props: Props)
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })
	local unavailableStorybookByNodeId = useRef({} :: { [string]: UnavailableStorybook })
	local snapshotSignaturesByStorybookSource = useRef({} :: { [Instance]: { [ModuleScript]: string } })
	local storyModuleNodesByStorybookSource = useRef({} :: { [Instance]: { [ModuleScript]: TreeNodeStore } })
	local storybookTreeSignaturesBySource = useRef({} :: { [Instance]: { unknown } })
	local lastOpenedStory, setLastOpenedStory = useLastOpenedStory()
	local storybooks = useStorybooks()
	local orphanedStoryModules = useOrphanedStoryModules()
	local nodesByInstance = useRef({} :: { [Instance]: TreeNodeStore })
	local orphanedStorybook = useMemo(createLoadedStorybook, {})
	local snapshotTargets = useMemo(function(): { StoryModuleTarget }
		local targets = {}
		local seen = {}

		for _, storybook in storybooks.available do
			for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
				seen[storyModule] = true
				table.insert(targets, {
					storyModule = storyModule,
					storybook = storybook,
				})
			end
		end

		for _, storyModule in orphanedStoryModules do
			if not seen[storyModule] then
				seen[storyModule] = true
				table.insert(targets, {
					storyModule = storyModule,
					storybook = orphanedStorybook,
				})
			end
		end

		return targets
	end, { storybooks.available, orphanedStoryModules, orphanedStorybook } :: { unknown })
	local storyModuleSnapshots = useStoryModuleSnapshots(snapshotTargets)

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

		return node.getName():lower():match(props.searchTerm:lower()) == nil
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
					if not node.getIsPinned() then
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
	useEffect(
		function()
			for _, storybook in storybooks.available do
				local storyModules = Storyteller.findStoryModulesForStorybook(storybook)
				local treeSignature = getStorybookTreeSignature(storybook, storyModules)
				local previousNode = nodesByInstance.current[storybook.source]
				if
					previousNode
					and areSameStorybookTreeSignatures(
						storybookTreeSignaturesBySource.current[storybook.source],
						treeSignature
					)
				then
					storybookByNodeId.current[previousNode.id] = storybook
					continue
				end

				local wasExpanded = if previousNode then previousNode.getIsExpanded() else false
				local previousSelection = if previousNode then getSelectedStoryNode(previousNode) else nil
				if previousNode then
					storybookByNodeId.current[previousNode.id] = nil
					unavailableStorybookByNodeId.current[previousNode.id] = nil
					previousNode.parentTo(nil)
				end

				local node = createTreeNodesForStorybook(storybook, storyModuleSnapshots)
				node.setIsExpanded(wasExpanded)
				nodesByInstance.current[storybook.source] = node
				storybookTreeSignaturesBySource.current[storybook.source] = treeSignature
				storybookByNodeId.current[node.id] = storybook
				local storyModuleNodes = indexStoryModuleNodes(node, storyModules)
				local snapshotSignatures = {}
				for storyModule in storyModuleNodes do
					local snapshotsForModule = storyModuleSnapshots[storyModule]
					local snapshot = if snapshotsForModule then snapshotsForModule[storybook.source] else nil
					if snapshot then
						snapshotSignatures[storyModule] = getSnapshotSignature(snapshot)
					end
				end
				storyModuleNodesByStorybookSource.current[storybook.source] = storyModuleNodes
				snapshotSignaturesByStorybookSource.current[storybook.source] = snapshotSignatures

				if pinnedInstanceStore.isPinned(storybook.source) then
					node.setIsPinned(true)
					node.parentTo(pinned)
				else
					node.parentTo(rootNode)
				end

				if previousSelection then
					local storyModule = previousSelection.getInstance()
					local storyId = previousSelection.getStoryId()
					if storyModule and storyModule:IsA("ModuleScript") then
						local nextStoryModuleNode = storyModuleNodes[storyModule]
						local nextSelection = if nextStoryModuleNode
							then findStoryNode(nextStoryModuleNode, storyId)
							else nil
						if nextSelection then
							nextSelection.setIsSelected(true)
							nextSelection.expandUp()
						end
					end
				end
			end
		end,
		{
			storybooks.available,
			snapshotTargets,
			pinnedInstanceStore.isPinned,
			pinned,
			rootNode,
		} :: { unknown }
	)

	-- Convert unavailable storybooks into nodes
	useEffect(function()
		unavailableStorybooks.setIsVisible(#storybooks.unavailable > 0)

		for _, unavailableStorybook in storybooks.unavailable do
			local source = unavailableStorybook.storybook.source
			local previousNode = nodesByInstance.current[source]
			if previousNode then
				if unavailableStorybookByNodeId.current[previousNode.id] then
					previousNode.setName(unavailableStorybook.storybook.name)
					unavailableStorybookByNodeId.current[previousNode.id] = unavailableStorybook
					continue
				end

				storybookByNodeId.current[previousNode.id] = nil
				previousNode.parentTo(nil)
				storyModuleNodesByStorybookSource.current[source] = nil
				snapshotSignaturesByStorybookSource.current[source] = nil
				storybookTreeSignaturesBySource.current[source] = nil
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
		local source = orphanedStorybook.source
		local storyModuleNodes = storyModuleNodesByStorybookSource.current[source] or {}
		local snapshotSignatures = snapshotSignaturesByStorybookSource.current[source] or {}

		for _, orphan in orphanedStoryModules do
			if nodesByInstance.current[orphan] then
				continue
			end

			local snapshotsForModule = storyModuleSnapshots[orphan]
			local snapshot = if snapshotsForModule then snapshotsForModule[source] else nil
			local node = createTreeNodeForStoryModule(orphan, snapshot)
			node.parentTo(unknownStories)
			nodesByInstance.current[orphan] = node
			storyModuleNodes[orphan] = node
			if snapshot then
				snapshotSignatures[orphan] = getSnapshotSignature(snapshot)
			end
		end
		storyModuleNodesByStorybookSource.current[source] = storyModuleNodes
		snapshotSignaturesByStorybookSource.current[source] = snapshotSignatures
	end, { orphanedStoryModules, orphanedStorybook, snapshotTargets, unknownStories } :: { unknown })

	-- Replace only the affected module node as snapshots arrive. Rebuilding an
	-- entire storybook for every background publication makes large storybooks
	-- progressively more expensive to discover.
	useEffect(function()
		for _, target in snapshotTargets do
			local source = target.storybook.source
			local snapshotsForModule = storyModuleSnapshots[target.storyModule]
			local snapshot = if snapshotsForModule then snapshotsForModule[source] else nil
			if not snapshot then
				continue
			end

			local storyModuleNodes = storyModuleNodesByStorybookSource.current[source]
			local previousNode = if storyModuleNodes then storyModuleNodes[target.storyModule] else nil
			if not previousNode then
				continue
			end

			local signature = getSnapshotSignature(snapshot)
			local snapshotSignatures = snapshotSignaturesByStorybookSource.current[source]
			if snapshotSignatures and snapshotSignatures[target.storyModule] == signature then
				continue
			end

			local parent = previousNode.getParent()
			if not parent then
				continue
			end

			local previousSelection = getSelectedStoryNode(previousNode)
			local storyId = if previousSelection then previousSelection.getStoryId() else nil
			local nextNode = createTreeNodeForStoryModule(target.storyModule, snapshot)
			nextNode.setIsExpanded(previousNode.getIsExpanded())
			local nextSelection = if previousSelection then findStoryNode(nextNode, storyId) else nil

			Charm.batch(function()
				nextNode.parentTo(parent)
				previousNode.parentTo(nil)
				if nextSelection then
					nextSelection.setIsSelected(true)
					nextSelection.expandUp()
				end
			end)

			storyModuleNodes[target.storyModule] = nextNode
			local nextSnapshotSignatures = snapshotSignatures or {}
			if nextSnapshotSignatures ~= snapshotSignatures then
				snapshotSignaturesByStorybookSource.current[source] = nextSnapshotSignatures
			end
			nextSnapshotSignatures[target.storyModule] = signature
			if target.storybook == orphanedStorybook then
				nodesByInstance.current[target.storyModule] = nextNode
			end
		end
	end, { orphanedStorybook, snapshotTargets, storyModuleSnapshots } :: { unknown })

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
				node.parentTo(nil)
				storybookByNodeId.current[node.id] = nil
				unavailableStorybookByNodeId.current[node.id] = nil
				nodesByInstance.current[instance] = nil
				storyModuleNodesByStorybookSource.current[instance] = nil
				snapshotSignaturesByStorybookSource.current[instance] = nil
				storybookTreeSignaturesBySource.current[instance] = nil
				if instance:IsA("ModuleScript") then
					local orphanedNodes = storyModuleNodesByStorybookSource.current[orphanedStorybook.source]
					local orphanedSignatures = snapshotSignaturesByStorybookSource.current[orphanedStorybook.source]
					if orphanedNodes then
						orphanedNodes[instance] = nil
					end
					if orphanedSignatures then
						orphanedSignatures[instance] = nil
					end
				end
			end
		end
	end, { storybooks.available, storybooks.unavailable, orphanedStoryModules, orphanedStorybook } :: { unknown })

	-- Reopening the story from the previous session
	local wasLastStoryOpened = useRef(false)
	local descendants = useSignalState(rootNode.getDescendants)
	useEffect(
		function()
			if wasLastStoryOpened.current then
				return
			end

			if lastOpenedStory then
				local storyModuleNode
				if lastOpenedStory.storybookSource then
					local nodesForStorybook = storyModuleNodesByStorybookSource.current[lastOpenedStory.storybookSource]
					storyModuleNode = if nodesForStorybook then nodesForStorybook[lastOpenedStory.storyModule] else nil
				else
					storyModuleNode = nodesByInstance.current[lastOpenedStory.storyModule]
						or findStoryModuleNode(rootNode, lastOpenedStory.storyModule)
				end
				local node = if storyModuleNode then findStoryNode(storyModuleNode, lastOpenedStory.storyId) else nil

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
						local icon = selectedNode.getIcon()
						local instance = selectedNode.getInstance()

						if icon == TreeView.TreeNodeIcon.Story and instance and instance:IsA("ModuleScript") then
							local storybookNode = selectedNode.findFirstAncestor(function(ancestor)
								return ancestor.getIcon() == TreeView.TreeNodeIcon.Storybook
							end)

							local storybook = if storybookNode then storybookByNodeId.current[storybookNode.id] else nil
							local storyId = selectedNode.getStoryId()

							props.onStoryChanged(instance, storybook, storyId)
							setLastOpenedStory(instance, if storybook then storybook.source else nil, storyId)
						end
					else
						props.onStoryChanged(nil, nil, nil)
					end
				end

				if props.onShowErrorPage then
					if selectedNode and selectedNode.getIcon() == TreeView.TreeNodeIcon.Alert then
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
