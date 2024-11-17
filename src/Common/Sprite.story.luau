local React = require("@pkg/React")
local Sprite = require("./Sprite")
local assets = require("@root/assets")

return {
	story = React.createElement("Folder", {}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Flipbook = React.createElement(Sprite, {
			layoutOrder = 1,
			image = assets.Flipbook,
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
