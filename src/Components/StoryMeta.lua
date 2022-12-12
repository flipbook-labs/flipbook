local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local types = require(script.Parent.Parent.types)
local useTheme = require(flipbook.Hooks.useTheme)
local hook = require(flipbook.hook)

local MAX_SUMMARY_SIZE = 600

local e = Roact.createElement

export type Props = {
	layoutOrder: number,
	story: types.Story,
}

local function StoryMeta(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = theme.padding,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Padding = e("UIPadding", {
			PaddingTop = theme.padding,
			PaddingRight = theme.padding,
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
		}),

		Title = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.headerFont,
			Size = UDim2.fromScale(0, 0),
			Text = props.story.name:sub(1, #props.story.name - 6),
			TextColor3 = theme.text,
			TextSize = theme.headerTextSize,
		}),

		Summary = props.story.summary and e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 0),
			Text = props.story.summary,
			TextColor3 = theme.textFaded,
			TextSize = theme.textSize,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {
			UISizeConstraint = e("UISizeConstraint", {
				MaxSize = Vector2.new(MAX_SUMMARY_SIZE, math.huge),
			}),
		}),
	})
end

return hook(StoryMeta)
