local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local InputField = require("@root/Forms/InputField")
local MockPlugin = require("@root/Testing/MockPlugin")
local TreeView = require("./TreeView")
local TreeViewContext = require("@root/TreeView/TreeViewContext")
local types = require("./types")

local useCallback = React.useCallback
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
			{
				label = "Folder 1",
				icon = types.TreeNodeIcon.Folder,
				children = {
					{
						label = "Folder 2",
						icon = types.TreeNodeIcon.Folder,
						children = {
							{
								label = "Folder 3",
								icon = types.TreeNodeIcon.Folder,
								children = {
									{
										id = "custom-id",
										label = "Deeply Nested Story",
										icon = types.TreeNodeIcon.Story,
									} :: PartialTreeNode,
								},
							} :: PartialTreeNode,
						},
					} :: PartialTreeNode,
				},
			} :: PartialTreeNode,
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

	local onExpand = useCallback(function()
		local node = treeViewContext.getNodeById("custom-id")
		if node then
			treeViewContext.activateNode(node)
		end
	end, { treeViewContext })

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

		Topbar = React.createElement("Frame", {
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 16),
			}),

			Search = React.createElement(InputField, {
				layoutOrder = 1,
				size = UDim2.fromScale(0.8, 1),
				placeholder = "Search...",
				onSubmit = setSearchTerm,
				onTextChange = setSearchTerm,
			}),

			ExpandToNode = React.createElement("TextButton", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.2, 1),
				Text = "Expand",
				[React.Event.Activated] = onExpand,
			}),
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
