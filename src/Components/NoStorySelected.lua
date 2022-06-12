local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local assets = require(flipbook.assets)
local hook = require(flipbook.hook)
local styles = require(flipbook.styles)
local useTheme = require(flipbook.Hooks.useTheme)

local function NoStorySelected(_, hooks: any)
	local theme = useTheme(hooks)

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
			BackgroundTransparency = 1,
			Image = assets.storybook,
			ImageColor3 = theme.text,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(64, 64),
		}),

		Message = Roact.createElement(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				LayoutOrder = 2,
				Text = "Select a story to preview it",
				TextColor3 = theme.text,
				TextSize = styles.TextLabel.TextSize * 1.5,
			})
		),
	})
end

return hook(NoStorySelected)
