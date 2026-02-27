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
	getName: () -> string,
	setName: (string | (string) -> string) -> string,
	getIcon: () -> TreeNodeIcon?,
	setIcon: (TreeNodeIcon? | (TreeNodeIcon?) -> TreeNodeIcon?) -> TreeNodeIcon?,
	getIsSelected: () -> boolean,
	setIsSelected: (boolean | (boolean) -> boolean) -> boolean,
	getIsVisible: () -> boolean,
	setIsVisible: (boolean | (boolean) -> boolean) -> boolean,
	activate: () -> (),
	getIsFiltered: () -> boolean,
	setIsFiltered: (boolean | (boolean) -> boolean) -> boolean,
	getIsPinned: () -> boolean,
	setIsPinned: (boolean | (boolean) -> boolean) -> boolean,

	-- Expand/Collapse
	getIsExpanded: () -> boolean,
	setIsExpanded: (boolean | (boolean) -> boolean) -> boolean,
	expandDown: () -> (),
	expandUp: () -> (),
	collapseDown: () -> (),

	-- Hierarchy
	getChildren: () -> { TreeNodeStore },
	setChildren: ({ TreeNodeStore } | ({ TreeNodeStore }) -> { TreeNodeStore }) -> { TreeNodeStore },
	getAncestors: () -> { TreeNodeStore },
	getDescendants: () -> { TreeNodeStore },
	getLeafNodes: () -> { TreeNodeStore },
	getPath: () -> string,
	getSelectedDescendants: () -> { TreeNodeStore },
	getPinnedDescendants: () -> { TreeNodeStore },
	getParent: () -> TreeNodeStore?,
	parentTo: (newParent: TreeNodeStore?) -> (),
	clearChildren: () -> (),
	findFirstDescendant: (predicate: (node: TreeNodeStore) -> boolean) -> TreeNodeStore?,
	findFirstAncestor: (predicate: (node: TreeNodeStore) -> boolean) -> TreeNodeStore?,
	getSortOrder: () -> TreeNodeSort?,
	setSortOrder: (sort: TreeNodeSort?) -> (),

	-- DataModel
	getInstance: () -> Instance?,
	setInstance: (Instance? | (Instance?) -> Instance?) -> Instance?,

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
