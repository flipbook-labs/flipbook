local React = require("@pkg/React")

local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local function AboutView()
	local theme = useTheme()

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = theme.padding,
		}),

		Logo = React.createElement(Sprite, {
			layoutOrder = nextLayoutOrder(),
			image = assets.IconLight,
			size = UDim2.fromOffset(42, 42),
		}),

		Title = React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(0, 0),
			Text = "flipbook",
			TextColor3 = theme.text,
			TextSize = theme.headerTextSize,
		}),
	})
end

return AboutView
