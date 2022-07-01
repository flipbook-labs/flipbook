local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local assets = require(flipbook.assets)
local hook = require(flipbook.hook)
local useTailwind = require(flipbook.Hooks.useTailwind)

local e = Roact.createElement

local function NoStorySelected()
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		UIListLayout = e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 16),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Icon = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = assets.Storybook,
			ImageColor3 = useTailwind("gray-800"),
			LayoutOrder = 1,
			Size = UDim2.fromOffset(32, 32),
		}),

		Message = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 0),
			Text = "Select a story to preview it",
			TextColor3 = useTailwind("gray-800"),
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
	})
end

return hook(NoStorySelected)
