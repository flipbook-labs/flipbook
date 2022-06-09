local assets = require(script.Parent.Parent.assets)
local hook = require(script.Parent.Parent.hook)
local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)
local useTheme = require(script.Parent.Parent.Hooks.useThemeNew)

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
