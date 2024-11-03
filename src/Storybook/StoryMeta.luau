local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local useTheme = require("@root/Common/useTheme")

local MAX_SUMMARY_SIZE = 600

local e = React.createElement

type Story = Storyteller.Story<unknown>

export type Props = {
	story: Story,
	layoutOrder: number?,
}

local function StoryMeta(props: Props)
	local theme = useTheme()

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

		Title = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.headerFont,
			Size = UDim2.fromScale(0, 0),
			Text = props.story.name,
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

return StoryMeta
