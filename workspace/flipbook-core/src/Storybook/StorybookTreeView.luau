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

local useCallback = React.useCallback
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
		pins.setIsVisible(#pinnedChildren > 0)
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
				node.parentTo(pins)
			end
		end
	end, { pinnedNodes, prevPinnedNodes, pins, rootNode } :: { unknown })

	-- Convert available storybooks into nodes
	useEffect(function()
		for _, storybook in props.storybooks.available do
			local node = createTreeNodesForStorybook(storybook :: any)
			storybookByNodeId.current[node.id] = storybook :: any

			if pinnedInstanceStore.isPinned(storybook.source) then
				node.setIsPinned(true)
				node.parentTo(pins)
			else
				node.parentTo(rootNode)
			end
		end
	end, { props.storybooks.available, pinnedInstanceStore.isPinned, pins, rootNode } :: { unknown })

	local unavailableStorybooks = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("Unavailable Storybooks")
		node.setIcon(TreeView.TreeNodeIcon.Folder)
		node.setIsVisible(false)
		node.parentTo(rootNode)

		return node
	end, { rootNode })

	-- Convert unavailable storybooks into nodes
	useEffect(function()
		unavailableStorybooks.clearChildren()

		if #props.storybooks.unavailable > 0 then
			unavailableStorybooks.setIsVisible(true)

			for _, unavailableStorybook in props.storybooks.unavailable do
				local node = TreeView.createTreeNodeStore()
				node.setName(unavailableStorybook.storybook.name)
				node.setIcon(TreeView.TreeNodeIcon.Alert)
				node.parentTo(unavailableStorybooks)

				unavailableStorybookByNodeId.current[rootNode.id] = unavailableStorybook
			end

			unavailableStorybooks.parentTo(rootNode)
		else
			unavailableStorybooks.setIsVisible(false)
		end
	end, { props.storybooks.unavailable, unavailableStorybooks })

	local orphanedStories = useMemo(function()
		local node = TreeView.createTreeNodeStore()
		node.setName("Unknown Stories")
		node.setIcon(TreeView.TreeNodeIcon.Folder)
		node.setIsVisible(false)
		node.parentTo(rootNode)

		return node
	end, { rootNode })

	-- Convert orphaned stories into nodes
	useEffect(function()
		orphanedStories.clearChildren()

		if props.orphanedStoryModules and #props.orphanedStoryModules > 0 then
			orphanedStories.setIsVisible(true)

			for _, orphan in props.orphanedStoryModules do
				local node = createTreeNodeForStoryModule(orphan)
				node.parentTo(orphanedStories)
			end
		else
			orphanedStories.setIsVisible(false)
		end
	end, { props.orphanedStoryModules, orphanedStories } :: { unknown })

	local wasLastStoryOpened = useRef(false)
	useEffect(function()
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
			end
		end
	end, { lastOpenedStory, rootNode } :: { unknown })

	useEffect(
		function()
			-- FIXME: Select a story, deselect, and try to select the same one
			-- again. Might be an issue with node activation

			if selectedNode ~= prevSelectedNode then
				print("selection changed")
				if props.onStoryChanged then
					if selectedNode then
						local icon = selectedNode.getIcon(false)
						local instance = selectedNode.getInstance(false)

						print("trying to open story from node", selectedNode.getName(false))

						if icon == TreeView.TreeNodeIcon.Story and instance and instance:IsA("ModuleScript") then
							local storybookNode = selectedNode.findFirstAncestor(function(ancestor)
								return ancestor.getIcon(false) == TreeView.TreeNodeIcon.Storybook
							end)

							print("storybookNode", storybookNode)

							-- FIXME: When loading the last opened story,
							-- storybookNode is nil for some reason
							if storybookNode then
								local storybook = storybookByNodeId.current[storybookNode.id]

								print("setLastOpenedStory", instance)
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
		filter = filter,
		layoutOrder = props.layoutOrder,
	})
end

return StorybookTreeView
