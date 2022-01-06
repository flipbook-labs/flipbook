local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local TreeNode = require(script.Parent.TreeNode)

export type Node = {
	name: string,
	icon: string?,
	instance: Instance?,
	children: { Node }?,
}

export type Props = {
	nodes: { Node },
}

local function TreeList(props: Props, hooks: any)
	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
	})

	for _, node in ipairs(props.nodes) do
		children[node.name] = Roact.createElement(TreeNode, {
			node = node,
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	})
end

return RoactHooks.new(Roact)(TreeList)
