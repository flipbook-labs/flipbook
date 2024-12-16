local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local ScrollingFrame = require("@root/Common/ScrollingFrame")
local SelectableTextLabel = require("@root/Forms/SelectableTextLabel")
local useTheme = require("@root/Common/useTheme")

export type Props = {
	err: string,
	layoutOrder: number?,
}

local function StoryError(props: Props)
	local theme = useTheme()

	local lineNumbers = Sift.List.reduce(props.err:split("\n"), function(accumulator, _item, index)
		return if index == 1 then tostring(index) else `{accumulator}\n{index}`
	end, "")

	return React.createElement(ScrollingFrame, {
		ScrollingDirection = Enum.ScrollingDirection.XY,
		LayoutOrder = props.layoutOrder,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = theme.padding,
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.paddingSmall,
			PaddingRight = theme.paddingSmall,
			PaddingBottom = theme.paddingSmall,
			PaddingLeft = theme.paddingSmall,
		}),

		LineNumbers = React.createElement("TextLabel", {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = lineNumbers,
			TextSize = theme.textSize,
			LineHeight = 1,
			BackgroundTransparency = 1,
			Font = Enum.Font.RobotoMono,
			TextColor3 = theme.textFaded,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),

		ErrorMessage = React.createElement(SelectableTextLabel, {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = props.err,
			TextColor3 = theme.alert,
			TextSize = theme.textSize,
			TextWrapped = false,
			LineHeight = 1,
			Font = Enum.Font.RobotoMono,
		}),
	})
end

return StoryError
