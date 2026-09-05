local Charm = require("@pkg/Charm")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")
local TreeView = require("@root/TreeView")

local PinnedInstanceStore = require("@root/Storybook/PinnedInstanceStore")
local StoryStore = require("@root/Storybook/StoryStore")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createTreeNodeForStoryModule = require("@root/Storybook/createTreeNodeForStoryModule")
local createTreeNodesForStorybook = require("@root/Storybook/createTreeNodesForStorybook")
local useLastOpenedStory = require("@root/Storybook/useLastOpenedStory")
local usePrevious = require("@root/Common/usePrevious")

type TreeNodeStore = TreeView.TreeNodeStore
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook
type StoryModuleRecord = Storyteller.StoryModuleRecord
type StoryRequest = Storyteller.StoryRequest

local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useSignalState = ReactCharm.useSignalState
local useStory = Storyteller.useStory
local useStoryModuleRecords = Storyteller.useStoryModuleRecords

export type Props = {
	searchTerm: string?,
	onStoryChanged: ((storyModule: ModuleScript?, storybook: LoadedStorybook?, storyId: string?) -> ())?,
	onShowErrorPage: ((unavailableStorybook: UnavailableStorybook) -> ())?,
	layoutOrder: number?,
}

type PrioritizedStoryRequestProps = {
	request: StoryRequest,
	storyId: string?,
}

local function PrioritizedStoryRequest(props: PrioritizedStoryRequestProps)
	useStory(props.request.storyModule, props.request.storybook, props.storyId)
	return nil
end

local function getRecordSignature(record: StoryModuleRecord): string
	local parts: { string } = {}
	if record.name then
		table.insert(parts, record.name)
	end
	if record.stories then
		for _, story in record.stories do
			table.insert(parts, story.id)
			table.insert(parts, story.name)
		end
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
		if storyId ~= nil and node.getStoryId() == nil then
			return nil
		end
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
	local recordSignaturesByStorybookSource = useRef({} :: { [Instance]: { [ModuleScript]: string } })
	local storyModuleNodesByStorybookSource = useRef({} :: { [Instance]: { [ModuleScript]: TreeNodeStore } })
	local storybookTreeSignaturesBySource = useRef({} :: { [Instance]: { unknown } })
	local lastOpenedStory, setLastOpenedStory = useLastOpenedStory()
	local storyStore = useSignalState(StoryStore.get)
	local storybooks = useSignalState(storyStore.getStorybooks)
	local orphanedStoryModules = useSignalState(storyStore.getOrphanedStoryModules)
	local nodesByInstance = useRef({} :: { [Instance]: TreeNodeStore })
	local orphanedStorybook = useMemo(createLoadedStorybook, {})
	local storyRequests = useMemo(function(): { StoryRequest }
		local requests = {}
		local seen = {}

		for _, storybook in storybooks.available do
			for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
				seen[storyModule] = true
				table.insert(requests, {
					storyModule = storyModule,
					storybook = storybook,
				})
			end
		end

		for _, storyModule in orphanedStoryModules do
			if not seen[storyModule] then
				seen[storyModule] = true
				table.insert(requests, {
					storyModule = storyModule,
					storybook = orphanedStorybook,
				})
			end
		end

		return requests
	end, { storybooks.available, orphanedStoryModules, orphanedStorybook } :: { unknown })
	local storyModuleRecords = useStoryModuleRecords(storyRequests)

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

	local getExpandedStorybookSources = useMemo(function()
		return Charm.computed(function(): { [Instance]: boolean }
			local sources = {}
			for _, node in rootNode.getDescendants() do
				if node.getIcon() == TreeView.TreeNodeIcon.Storybook and node.getIsExpanded() then
					local source = node.getInstance()
					if source then
						sources[source] = true
					end
				end
			end
			return sources
		end)
	end, { rootNode })
	local expandedStorybookSources = useSignalState(getExpandedStorybookSources)
	local isUnknownStoriesExpanded = useSignalState(unknownStories.getIsExpanded)
	local prioritizedStoryRequests = useMemo(
		function(): { PrioritizedStoryRequestProps }
			local requests = {}

			for _, request in storyRequests do
				local isLastOpenedStory = lastOpenedStory ~= nil
					and request.storyModule == lastOpenedStory.storyModule
					and (
						lastOpenedStory.storybookSource == nil
						or request.storybook.source == lastOpenedStory.storybookSource
					)
				local isExpanded = expandedStorybookSources[request.storybook.source]
					or (request.storybook == orphanedStorybook and isUnknownStoriesExpanded)
				if isExpanded or isLastOpenedStory then
					table.insert(requests, {
						request = request,
						storyId = if isLastOpenedStory and lastOpenedStory then lastOpenedStory.storyId else nil,
					})
				end
			end

			return requests
		end,
		{
			expandedStorybookSources,
			isUnknownStoriesExpanded,
			lastOpenedStory,
			orphanedStorybook,
			storyRequests,
		} :: { unknown }
	)

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

				local node = createTreeNodesForStorybook(storybook, storyModuleRecords)
				node.setIsExpanded(wasExpanded)
				nodesByInstance.current[storybook.source] = node
				storybookTreeSignaturesBySource.current[storybook.source] = treeSignature
				storybookByNodeId.current[node.id] = storybook
				local storyModuleNodes = indexStoryModuleNodes(node, storyModules)
				local recordSignatures = {}
				for storyModule in storyModuleNodes do
					local recordsForStorybook = storyModuleRecords[storybook.source]
					local record = if recordsForStorybook then recordsForStorybook[storyModule] else nil
					if record then
						recordSignatures[storyModule] = getRecordSignature(record)
					end
				end
				storyModuleNodesByStorybookSource.current[storybook.source] = storyModuleNodes
				recordSignaturesByStorybookSource.current[storybook.source] = recordSignatures

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
			storyRequests,
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
			local previousSelection = if previousNode then getSelectedStoryNode(previousNode) else nil
			if previousNode then
				if unavailableStorybookByNodeId.current[previousNode.id] then
					previousNode.setName(unavailableStorybook.storybook.name)
					unavailableStorybookByNodeId.current[previousNode.id] = unavailableStorybook
					continue
				end

				storybookByNodeId.current[previousNode.id] = nil
				previousNode.parentTo(nil)
				storyModuleNodesByStorybookSource.current[source] = nil
				recordSignaturesByStorybookSource.current[source] = nil
				storybookTreeSignaturesBySource.current[source] = nil
			end

			local node = TreeView.createTreeNodeStore()
			node.setName(unavailableStorybook.storybook.name)
			node.setIcon(TreeView.TreeNodeIcon.Alert)
			node.parentTo(unavailableStorybooks)

			nodesByInstance.current[source] = node
			unavailableStorybookByNodeId.current[node.id] = unavailableStorybook
			if previousSelection then
				node.setIsSelected(true)
				node.expandUp()
			end
		end
	end, { storybooks.unavailable, unavailableStorybooks })

	-- Convert orphaned stories into nodes
	useEffect(function()
		unknownStories.setIsVisible(#orphanedStoryModules > 0)
		local source = orphanedStorybook.source
		local storyModuleNodes = storyModuleNodesByStorybookSource.current[source] or {}
		local recordSignatures = recordSignaturesByStorybookSource.current[source] or {}

		for _, orphan in orphanedStoryModules do
			if nodesByInstance.current[orphan] then
				continue
			end

			local recordsForStorybook = storyModuleRecords[source]
			local record = if recordsForStorybook then recordsForStorybook[orphan] else nil
			local node = createTreeNodeForStoryModule(orphan, record)
			node.parentTo(unknownStories)
			nodesByInstance.current[orphan] = node
			storyModuleNodes[orphan] = node
			if record then
				recordSignatures[orphan] = getRecordSignature(record)
			end
		end
		storyModuleNodesByStorybookSource.current[source] = storyModuleNodes
		recordSignaturesByStorybookSource.current[source] = recordSignatures
	end, { orphanedStoryModules, orphanedStorybook, storyRequests, unknownStories } :: { unknown })

	-- Replace only the affected module node as records arrive. Rebuilding an
	-- entire storybook for every background publication makes large storybooks
	-- progressively more expensive to discover.
	useEffect(function()
		for _, request in storyRequests do
			local source = request.storybook.source
			local recordsForStorybook = storyModuleRecords[source]
			local record = if recordsForStorybook then recordsForStorybook[request.storyModule] else nil
			if not record then
				continue
			end

			local storyModuleNodes = storyModuleNodesByStorybookSource.current[source]
			local previousNode = if storyModuleNodes then storyModuleNodes[request.storyModule] else nil
			if not previousNode then
				continue
			end

			local signature = getRecordSignature(record)
			local recordSignatures = recordSignaturesByStorybookSource.current[source]
			if recordSignatures and recordSignatures[request.storyModule] == signature then
				continue
			end

			local parent = previousNode.getParent()
			if not parent then
				continue
			end

			local previousSelection = getSelectedStoryNode(previousNode)
			local storyId = if previousSelection then previousSelection.getStoryId() else nil
			local nextNode = createTreeNodeForStoryModule(request.storyModule, record)
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

			storyModuleNodes[request.storyModule] = nextNode
			local nextRecordSignatures = recordSignatures or {}
			if nextRecordSignatures ~= recordSignatures then
				recordSignaturesByStorybookSource.current[source] = nextRecordSignatures
			end
			nextRecordSignatures[request.storyModule] = signature
			if request.storybook == orphanedStorybook then
				nodesByInstance.current[request.storyModule] = nextNode
			end
		end
	end, { orphanedStorybook, storyRequests, storyModuleRecords } :: { unknown })

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
				recordSignaturesByStorybookSource.current[instance] = nil
				storybookTreeSignaturesBySource.current[instance] = nil
				if instance:IsA("ModuleScript") then
					local orphanedNodes = storyModuleNodesByStorybookSource.current[orphanedStorybook.source]
					local orphanedSignatures = recordSignaturesByStorybookSource.current[orphanedStorybook.source]
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
			storyModuleRecords,
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

	local children: { [string]: React.ReactNode } = {
		TreeView = React.createElement(TreeView.TreeView, {
			root = rootNode,
			filter = filter,
			layoutOrder = props.layoutOrder,
		}),
	}
	for index, prioritizedRequest in prioritizedStoryRequests do
		children[`PrioritizedStoryRequest{index}`] = React.createElement(PrioritizedStoryRequest, {
			request = prioritizedRequest.request,
			storyId = prioritizedRequest.storyId,
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

return StorybookTreeView
