local Signals = require("@rbxpkg/Signals")

local types = {}

export type TreeNodeIcon = "none" | "story" | "storybook" | "folder" | "alert" | "pin"

types.TreeNodeIcon = {
	None = "none" :: "none",
	Story = "story" :: "story",
	Storybook = "storybook" :: "storybook",
	Folder = "folder" :: "folder",
	Alert = "alert" :: "alert",
	Pin = "pin" :: "pin",
}

export type TreeNodeFilter = (node: TreeNodeStore) -> boolean

export type TreeNodeStore = {
	id: string,

	-- Node properties and states
	getName: Signals.getter<string>,
	setName: Signals.setter<string>,
	getIcon: Signals.getter<TreeNodeIcon?>,
	setIcon: Signals.setter<TreeNodeIcon?>,
	getIsSelected: Signals.getter<boolean>,
	setIsSelected: Signals.setter<boolean>,
	getIsVisible: Signals.getter<boolean>,
	setIsVisible: Signals.setter<boolean>,
	activate: () -> (),
	getIsFiltered: Signals.getter<boolean>,
	setIsFiltered: Signals.setter<boolean>,
	getIsPinned: Signals.getter<boolean>,
	setIsPinned: Signals.setter<boolean>,

	-- Expand/Collapse
	getIsExpanded: Signals.getter<boolean>,
	setIsExpanded: Signals.setter<boolean>,
	expandDown: () -> (),
	expandUp: () -> (),
	collapseDown: () -> (),

	-- Hierarchy
	getChildren: Signals.getter<{ TreeNodeStore }>,
	setChildren: Signals.setter<{ TreeNodeStore }>,
	getAncestors: Signals.getter<{ TreeNodeStore }>,
	getDescendants: Signals.getter<{ TreeNodeStore }>,
	getLeafNodes: Signals.getter<{ TreeNodeStore }>,
	getSelectedDescendants: Signals.getter<{ TreeNodeStore }>,
	getPinnedDescendants: Signals.getter<{ TreeNodeStore }>,
	getParent: Signals.getter<TreeNodeStore?>,
	parentTo: (newParent: TreeNodeStore?) -> (),
	findFirstDescendant: (predicate: (node: TreeNodeStore) -> boolean) -> TreeNodeStore?,
	findFirstAncestor: (predicate: (node: TreeNodeStore) -> boolean) -> TreeNodeStore?,

	-- DataModel
	getInstance: Signals.getter<Instance?>,
	setInstance: Signals.setter<Instance?>,

	-- Other
	snapshot: () -> TreeNodeSnapshot,
}

export type TreeNodeSnapshot = {
	id: string,
	name: string,
	icon: string?,
	isSelected: boolean,
	isVisible: boolean,
	instance: Instance?,
	children: { TreeNodeSnapshot },
}

return types
