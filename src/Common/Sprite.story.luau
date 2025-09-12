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
			image = assets.FlipbookIcon,
		}),
	}),
}
