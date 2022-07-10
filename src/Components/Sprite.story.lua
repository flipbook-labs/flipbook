local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local assets = require(flipbook.assets)
local Sprite = require(script.Parent.Sprite)

return {
	story = Roact.createElement("Folder", {}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		flipbook = Roact.createElement(Sprite, {
			layoutOrder = 1,
			image = assets.flipbook,
		}),

		Storybook = Roact.createElement(Sprite, {
			layoutOrder = 2,
			image = assets.Storybook,
		}),

		Folder = Roact.createElement(Sprite, {
			layoutOrder = 3,
			image = assets.Folder,
		}),

		Component = Roact.createElement(Sprite, {
			layoutOrder = 4,
			image = assets.Component,
		}),
	}),
}
