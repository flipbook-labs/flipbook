export type TreeNode = {
	id: string,
	label: string,
	icon: string?,
	children: { TreeNode }?,
	parent: TreeNode?,
}

export type Tree = {
	root: TreeNode,
	leafNodes: { TreeNode },
	nodesById: { [string]: TreeNode },
}

return nil
