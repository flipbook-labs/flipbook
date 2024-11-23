local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local TreeView = require("./TreeView")
local types = require("./types")

type PartialTreeNode = types.PartialTreeNode

return {
	story = function()
		local roots: { PartialTreeNode } = {
			{
				label = "Pinned Storybooks",
				icon = types.TreeNodeIcon.None,
				isExpanded = true,
				children = {
					{
						label = "Storybook 1",
						icon = types.TreeNodeIcon.Storybook,
						isExpanded = false,
						children = {
							-- ...
						},
					},
				},
			},
			{
				label = "Storybook 1",
				icon = types.TreeNodeIcon.Storybook,
				isExpanded = false,
				children = {
					-- ...
				},
			},

			{
				label = "Storybook 2",
				icon = types.TreeNodeIcon.Storybook,
				isExpanded = true,
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
			},
		}
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Wrapper = React.createElement("Frame", {
				Size = UDim2.fromOffset(300, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, {

				TreeView = React.createElement(TreeView, {
					roots = roots,
				}),
			}),
		})
	end,
}
