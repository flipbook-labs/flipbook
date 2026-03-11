local CharmTypes = require("@root/Common/CharmTypes")

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

export type TreeNodeSort = (a: TreeNodeStore, b: TreeNodeStore) -> boolean

export type TreeNodeStore = {
	id: string,

	-- Node properties and states
	getName: CharmTypes.Getter<string>,
	setName: CharmTypes.Setter<string>,
	getIcon: CharmTypes.Getter<TreeNodeIcon?>,
	setIcon: CharmTypes.Setter<TreeNodeIcon?>,
	getIsSelected: CharmTypes.Getter<boolean>,
	setIsSelected: CharmTypes.Setter<boolean>,
	getIsVisible: CharmTypes.Getter<boolean>,
	setIsVisible: CharmTypes.Setter<boolean>,
	activate: () -> (),
	getIsFiltered: CharmTypes.Getter<boolean>,
	setIsFiltered: CharmTypes.Setter<boolean>,
	getIsPinned: CharmTypes.Getter<boolean>,
	setIsPinned: CharmTypes.Setter<boolean>,

	-- Expand/Collapse
	getIsExpanded: CharmTypes.Getter<boolean>,
	setIsExpanded: CharmTypes.Setter<boolean>,
	expandDown: () -> (),
	expandUp: () -> (),
	collapseDown: () -> (),

	-- Hierarchy
	getChildren: CharmTypes.Getter<{ TreeNodeStore }>,
	setChildren: CharmTypes.Setter<{ TreeNodeStore }>,
	getAncestors: CharmTypes.Getter<{ TreeNodeStore }>,
	getDescendants: CharmTypes.Getter<{ TreeNodeStore }>,
	getLeafNodes: CharmTypes.Getter<{ TreeNodeStore }>,
	getPath: CharmTypes.Getter<string>,
	getSelectedDescendants: CharmTypes.Getter<{ TreeNodeStore }>,
	getPinnedDescendants: CharmTypes.Getter<{ TreeNodeStore }>,
	getParent: CharmTypes.Getter<TreeNodeStore?>,
	parentTo: (newParent: TreeNodeStore?) -> (),
	clearChildren: () -> (),
	findFirstDescendant: (predicate: (node: TreeNodeStore) -> boolean) -> TreeNodeStore?,
	findFirstAncestor: (predicate: (node: TreeNodeStore) -> boolean) -> TreeNodeStore?,
	getSortOrder: CharmTypes.Getter<TreeNodeSort?>,
	setSortOrder: (sort: TreeNodeSort?) -> (),

	-- DataModel
	getInstance: CharmTypes.Getter<Instance?>,
	setInstance: CharmTypes.Setter<Instance?>,

	-- Other
	snapshot: () -> TreeNodeSnapshot,
	-- destroy: () -> (),
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
