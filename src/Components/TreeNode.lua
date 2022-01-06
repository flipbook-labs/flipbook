local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local assets = require(script.Parent.Parent.assets)
local TreeList = require(script.Parent.TreeList)

local INDENT_SIZE = 24 -- px
local ARROW_SIZE = 16 -- px

export type Props = {
	node: TreeList.Node,
	indentLevel: number,
}

local function TreeNode(props: Props, hooks: any)
	local isExpanded = hooks.useState(false)
	local childrenHeight = hooks.useState(0)

	local children = {}

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, ARROW_SIZE),
		BackgroundTransparency = 1,
	}, {
		Arrow = Roact.createElement("ImageLabel", {
			Image = assets["chevron-right"],
			Size = UDim2.fromOffset(ARROW_SIZE, ARROW_SIZE),
			BackgroundTransparency = 1,
		}),

		Text = Roact.createElement("TextLabel", {
			Text = props.node.name,
			TextSize = ARROW_SIZE,
			Position = UDim2.fromOffset(0, ARROW_SIZE),
			Size = UDim2.new(1, -ARROW_SIZE, 0, ARROW_SIZE),
			BackgroundTransparency = 1,
		}),

		Children = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, childrenHeight),
		}),
	})
end

return RoactHooks.new(Roact)(TreeNode)
