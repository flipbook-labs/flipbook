local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local assets = require(script.Parent.Parent.Parent.assets)
local TreeList = require(script.Parent)
local types = require(script.Parent.types)

return {
	story = Roact.createElement(TreeList, {
		onNodeActivated = function(node: types.Node)
			print(node.name, "activated")
		end,
		nodes = {
			{
				name = "flipbook",
				icon = assets.storybook,
				children = {
					{
						name = "Components",
						icon = assets.folder,
						children = {
							{
								name = "App.story",
								icon = assets.story,
							},
							{
								name = "Sample.story",
								icon = assets.story,
							},
						},
					},
				},
			},
			{
				name = "AnotherStorybook",
				icon = assets.storybook,
				children = {
					{
						name = "Components",
						icon = assets.folder,
						children = {
							{
								name = "App.story",
								icon = assets.story,
							},
							{
								name = "Sample.story",
								icon = assets.story,
							},
						},
					},
				},
			},
		},
	}),
}
