local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)
local types = require(flipbook.types)
local useTailwind = require(flipbook.Hooks.useTailwind)

local MAX_SUMMARY_SIZE = 600

local e = Roact.createElement

export type Props = {
	layoutOrder: number,
	story: types.Story,
}

local function StoryMeta(props: Props, hooks: any)
	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Title = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.fromScale(0, 0),
			Text = props.story.name:sub(1, #props.story.name - 6),
			TextColor3 = useTailwind("gray-800"),
			TextSize = 24,
		}),

		Summary = props.story.summary and e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 0),
			Text = props.story.summary,
			TextColor3 = useTailwind("gray-800"),
			TextSize = 16,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			UISizeConstraint = e("UISizeConstraint", {
				MaxSize = Vector2.new(MAX_SUMMARY_SIZE, math.huge),
			}),
		}),
	})
end

return hook(StoryMeta)
