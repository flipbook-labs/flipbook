local React = require("@pkg/React")
local assets = require("@root/assets")
local Sprite = require("./Sprite")

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
