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

local function getSnapshotSignature(
	storyModules: { ModuleScript },
	snapshots: { [ModuleScript]: StoryModuleSnapshot }
): string?
	local parts = {}
	for _, storyModule in storyModules do
		local snapshot = snapshots[storyModule]
		if not snapshot then
			return nil
		end

		table.insert(parts, storyModule:GetFullName())
		table.insert(parts, snapshot.name)
		table.insert(parts, snapshot.problem or "")
		for _, story in snapshot.stories do
			table.insert(parts, story.id)
			table.insert(parts, story.name)
		end
	end
	return table.concat(parts, "\0")
end

local function areSameModules(a: { ModuleScript }?, b: { ModuleScript }): boolean
	if not a or #a ~= #b then
		return false
	end

	for index, storyModule in a do
		if storyModule ~= b[index] then
			return false
		end
	end
	return true
end

local function StorybookTreeView(props: Props)
	local storybookByNodeId = useRef({} :: { [string]: LoadedStorybook })
	local unavailableStorybookByNodeId = useRef({} :: { [string]: UnavailableStorybook })
	local snapshotSignaturesByInstance = useRef({} :: { [Instance]: string })
	local storyModulesByStorybookSource = useRef({} :: { [Instance]: { ModuleScript } })
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
				if not seen[storyModule] then
					seen[storyModule] = true
					table.insert(targets, {
						storyModule = storyModule,
						storybook = storybook,
					})
				end
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
				local signature = getSnapshotSignature(storyModules, storyModuleSnapshots)
				if not signature then
					continue
				end

				local previousNode = nodesByInstance.current[storybook.source]
				if
					previousNode
					and snapshotSignaturesByInstance.current[storybook.source] == signature
					and areSameModules(storyModulesByStorybookSource.current[storybook.source], storyModules)
				then
					continue
				end

				local wasExpanded = if previousNode then previousNode.getIsExpanded() else false
				local previousSelection = if previousNode
					then previousNode.findFirstDescendant(function(descendant)
						return descendant.getIsSelected()
					end)
					else nil
				if previousNode then
					storybookByNodeId.current[previousNode.id] = nil
					previousNode.parentTo(nil)
				end

				local node = createTreeNodesForStorybook(storybook :: any, storyModuleSnapshots)
				node.setIsExpanded(wasExpanded)
				nodesByInstance.current[storybook.source] = node
				snapshotSignaturesByInstance.current[storybook.source] = signature
				storyModulesByStorybookSource.current[storybook.source] = storyModules
				storybookByNodeId.current[node.id] = storybook :: any

				if pinnedInstanceStore.isPinned(storybook.source) then
					node.setIsPinned(true)
					node.parentTo(pinned)
				else
					node.parentTo(rootNode)
				end

				if previousSelection then
					local storyModule = previousSelection.getInstance()
					local storyId = previousSelection.getStoryId()
					local nextSelection = node.findFirstDescendant(function(descendant)
						return descendant.getIcon() == TreeView.TreeNodeIcon.Story
							and descendant.getInstance() == storyModule
							and descendant.getStoryId() == storyId
					end)
					if nextSelection then
						nextSelection.setIsSelected(true)
						nextSelection.expandUp()
					end
				end
			end
		end,
		{
			storybooks.available,
			storyModuleSnapshots,
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
			local signature = getSnapshotSignature({ orphan }, storyModuleSnapshots)
			if not signature then
				continue
			end

			local previousNode = nodesByInstance.current[orphan]
			if previousNode and snapshotSignaturesByInstance.current[orphan] == signature then
				continue
			end

			if previousNode then
				previousNode.parentTo(nil)
			end

			local node = createTreeNodeForStoryModule(orphan, storyModuleSnapshots[orphan])
			node.parentTo(unknownStories)
			nodesByInstance.current[orphan] = node
			snapshotSignaturesByInstance.current[orphan] = signature
		end
	end, { orphanedStoryModules, storyModuleSnapshots, unknownStories } :: { unknown })

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
				nodesByInstance.current[instance] = nil
				snapshotSignaturesByInstance.current[instance] = nil
				storyModulesByStorybookSource.current[instance] = nil
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
					return descendant.getIcon() == TreeView.TreeNodeIcon.Story
						and descendant.getInstance() == lastOpenedStory.storyModule
						and (lastOpenedStory.storyId == nil or descendant.getStoryId() == lastOpenedStory.storyId)
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
						local icon = selectedNode.getIcon()
						local instance = selectedNode.getInstance()

						if icon == TreeView.TreeNodeIcon.Story and instance and instance:IsA("ModuleScript") then
							local storybookNode = selectedNode.findFirstAncestor(function(ancestor)
								return ancestor.getIcon() == TreeView.TreeNodeIcon.Storybook
							end)

							local storybook = if storybookNode then storybookByNodeId.current[storybookNode.id] else nil
							local storyId = selectedNode.getStoryId()

							props.onStoryChanged(instance, storybook, storyId)
							setLastOpenedStory(instance, storyId)
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
