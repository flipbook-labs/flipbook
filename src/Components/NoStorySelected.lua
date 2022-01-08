local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local assets = require(script.Parent.Parent.assets)
local styles = require(script.Parent.Parent.styles)

local function NoStorySelected()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = styles.PADDING,
		}),

		Icon = Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			Image = assets.storybook,
			Size = UDim2.fromOffset(64, 64),
			BackgroundTransparency = 1,
		}),

		Message = Roact.createElement(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				LayoutOrder = 2,
				TextSize = styles.TextLabel.TextSize * 1.5,
				Text = "Select a story to preview it",
			})
		),
	})
end

return NoStorySelected
