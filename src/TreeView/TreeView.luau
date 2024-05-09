local React = require("@pkg/React")

local treeViewTypes = require("@root/TreeView/types")

local useMemo = React.useMemo

type TreeNode = treeViewTypes.TreeNode
type Tree = treeViewTypes.Tree

export type Props = {
	roots: { TreeNode },
	expandedNodes: { TreeNode }?,
	onActivated: ((node: TreeNode) -> ())?,
	filter: ((node: TreeNode) -> boolean)?,
}

local function TreeView(props: Props)
	local nodesById = useMemo(function() end, { props.tree })

	local leafNodes = useMemo(function() end, { props.tree })

	local children = {}
	for _, node in props.roots do
		children[node.label] = React.createElement("ImageButton", {
			AutoButtonColor = false,
			[React.Event.Activated] = function()
				props.onActivated(node)
			end,
		}, {
			Label = React.createElement("Frame", {}, {
				Icon = React.createElement("ImageLabel", {}),

				Text = React.createElement("TextLabel", {
					Text = node.label,
				}),
			}),

			Toggle = React.createElement("ImageLabel", {}),
		})
	end

	return React.createElement("Frame", {}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}, children)
end

return TreeView
