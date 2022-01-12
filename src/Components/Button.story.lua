local Roact = require(script.Parent.Parent.Packages.Roact)
local assets = require(script.Parent.Parent.assets)
local Button = require(script.Parent.Button)

local PADDING = UDim.new(0, 16)

return {
	roact = Roact,
	story = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 16),
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = PADDING,
			PaddingRight = PADDING,
			PaddingBottom = PADDING,
			PaddingLeft = PADDING,
		}),

		TextButton = Roact.createElement(Button, {
			layoutOrder = 1,
			text = "Click me",
			onActivated = function()
				print("TextButton clicked")
			end,
		}),

		ImageButton = Roact.createElement(Button, {
			layoutOrder = 2,
			icon = assets.viewport,
			onActivated = function()
				print("ImageButton clicked")
			end,
		}),

		Both = Roact.createElement(Button, {
			layoutOrder = 3,
			text = "Explore",
			icon = assets.explore,
			onActivated = function()
				print("Image + Text button clicked")
			end,
		}),
	}),
}
