local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local TreeView = require("./TreeView")
local types = require("./types")

return {
	story = function()
		local tree: types.TreeNode = {
			id = "1",
			label = "Top",
			children = {
				{
					id = "2",
					label = "Child",
					isExpanded = true,
					children = {},
				},

				{
					id = "3",
					label = "Sibling",
					children = {
						{
							id = "4",
							label = "Descendant",
							isExpanded = false,
							children = {},
						},
					},
				},
			},
		}
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			TreeView = React.createElement(TreeView, {
				roots = {
					tree,
				},
			}),
		})
	end,
}
