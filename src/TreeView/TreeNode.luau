local React = require("@pkg/React")

local treeViewTypes = require("@root/TreeView/types")
local useTheme = require("@root/Common/useTheme")

local useMemo = React.useMemo

type TreeNode = treeViewTypes.TreeNode

export type Props = {
	node: TreeNode,
}

local function TreeNode(props: Props)
	local theme = useTheme()

	local children = useMemo(function()
		if props.node.children then
			local elements = {}
			for _, child in props.node.children do
				elements[child.id] = React.createElement(TreeNode, {
					node = child,
				})
			end
			return elements
		end
	end, { props.node.children })

	return React.createElement("ImageButton", {
		AutoButtonColor = false,
		[React.Event.Activated] = function()
			props.onActivated(props.node)
		end,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Node = React.createElement("Frame", {
			LayoutOrder = 1,
		}, {
			Icon = React.createElement("ImageLabel", {}),

			Text = React.createElement("TextLabel", {
				Text = props.node.label,
			}),

			Toggle = React.createElement("ImageLabel", {}),
		}),

		Children = React.createElement("Frame", {
			LayoutOrder = 2,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}, children),
	})
end

return TreeNode
