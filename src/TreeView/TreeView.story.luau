local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local InputField = require("@root/Forms/InputField")
local MockPlugin = require("@root/Testing/MockPlugin")
local TreeView = require("./TreeView")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local types = require("./types")

local useEffect = React.useEffect
local useState = React.useState

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode

local roots: { PartialTreeNode } = {
	{
		label = "Pinned Storybooks",
		icon = types.TreeNodeIcon.None,
		isExpanded = true,
		children = {
			{
				label = "Storybook 1",
				icon = types.TreeNodeIcon.Storybook,
				children = {
					-- ...
				},
			},
		},
	},
	{
		label = "Storybook 1",
		icon = types.TreeNodeIcon.Storybook,
		children = {
			-- ...
		},
	},

	{
		label = "Storybook 2",
		icon = types.TreeNodeIcon.Storybook,
		children = {
			{
				label = "Folder",
				icon = types.TreeNodeIcon.Folder,
				isExpanded = true,
				children = {
					{
						label = "Story 1",
						icon = types.TreeNodeIcon.Story,
					},
					{
						label = "Story 2",
						icon = types.TreeNodeIcon.Story,
					},
				},
			} :: PartialTreeNode,
			{
				label = "Story 1",
				icon = types.TreeNodeIcon.Story,
			},
			{
				label = "Story 2",
				icon = types.TreeNodeIcon.Story,
			},
			{
				label = "Story 3",
				icon = types.TreeNodeIcon.Story,
			},
		},
	},
	{
		label = "Storybook 3",
		icon = types.TreeNodeIcon.Storybook,
		children = {
			-- ...
		},
	},
	{
		label = "Unnamed Storybook",
		icon = types.TreeNodeIcon.Storybook,
		children = {
			-- ...
		},
	},
	{
		label = "Unknown Stories",
		icon = types.TreeNodeIcon.Storybook,
		children = {
			{
				label = "Story 1",
				icon = types.TreeNodeIcon.Story,
			},
			{
				label = "Story 2",
				icon = types.TreeNodeIcon.Story,
			},
		},
	},
}

local function Story()
	local treeViewContext = TreeViewContext.use()

	useEffect(function()
		treeViewContext.setRoots(roots)
	end, {})

	local searchTerm: string?, setSearchTerm = useState(nil :: string?)

	useEffect(function()
		treeViewContext.search(searchTerm)
	end, { treeViewContext, searchTerm } :: { unknown })

	return React.createElement("Frame", {
		Size = UDim2.fromOffset(300, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 16),
		}),

		Search = React.createElement(InputField, {
			layoutOrder = 1,
			size = UDim2.new(1, 0, 0, 16),
			onSubmit = setSearchTerm,
			onTextChange = setSearchTerm,
		}),

		TreeView = React.createElement(TreeView, {
			layoutOrder = 2,
		}),
	})
end

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Story = React.createElement(Story),
		})
	end,
}
