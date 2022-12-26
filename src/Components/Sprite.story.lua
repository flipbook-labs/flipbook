local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local assets = require(flipbook.assets)
local Sprite = require(script.Parent.Sprite)

return {
	story = React.createElement("Folder", {}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		flipbook = React.createElement(Sprite, {
			layoutOrder = 1,
			image = assets.flipbook,
		}),

		Storybook = React.createElement(Sprite, {
			layoutOrder = 2,
			image = assets.Storybook,
		}),

		Folder = React.createElement(Sprite, {
			layoutOrder = 3,
			image = assets.Folder,
		}),

		Component = React.createElement(Sprite, {
			layoutOrder = 4,
			image = assets.Component,
		}),
	}),
}
