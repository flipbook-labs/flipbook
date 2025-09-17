local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
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

	return React.createElement(Foundation.View, {
		tag = "auto-y col gap-large",
		Size = UDim2.fromOffset(300, 0),
	}, {
		Topbar = React.createElement(Foundation.View, {
			tag = "size-full-0 auto-y row gap-large",
			LayoutOrder = 1,
		}, {
			Search = React.createElement(Foundation.TextInput, {
				text = "",
				label = "",
				placeholder = "Search...",
				size = Foundation.Enums.InputSize.Medium,
				width = UDim.new(1, 0),
				iconLeading = Foundation.Enums.IconName.MagnifyingGlass,
				onChanged = setSearchTerm,
				LayoutOrder = 1,
			}),

			ExpandToNode = React.createElement(Foundation.Button, {
				text = "Expand",
				size = Foundation.Enums.ButtonSize.Small,
				onActivated = onExpand,
				LayoutOrder = 2,
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
