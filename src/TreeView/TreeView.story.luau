local React = require("@pkg/React")

local TreeView = require("./TreeView")

return {
	story = function()
		return React.createElement(TreeView, {
			roots = {
				{
					id = "1",
					label = "Top",
					children = {
						{
							id = "2",
							label = "Child",
							parent = "1",
							children = {
								{},
							},
						},

						{
							id = "3",
							label = "Sibling",
							parent = "1",
							children = {},
						},
					},
				},
			},
		})
	end,
}
