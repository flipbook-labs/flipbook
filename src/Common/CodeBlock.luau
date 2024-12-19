local Highlighter = require("@pkg/Highlighter")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local SelectableTextLabel = require("@root/Forms/SelectableTextLabel")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useMemo = React.useMemo

local function getLineNumbers(str: string): string
	return Sift.List.reduce(str:split("\n"), function(accumulator, _item, index)
		return if index == 1 then tostring(index) else `{accumulator}\n{index}`
	end, "")
end

export type Props = {
	source: string,
	sourceColor: Color3?,
	layoutOrder: number?,
}

local function CodeBlock(props: Props)
	local theme = useTheme()

	local sourceColor = useMemo(function()
		return if props.sourceColor then props.sourceColor else theme.text
	end, { props.sourceColor })

	local source = useMemo(function()
		if props.sourceColor then
			return props.source
		else
			return table.concat(
				Highlighter.buildRichTextLines({
					src = props.source,
				}),
				"\n"
			)
		end
	end, { props.source })

	return React.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundColor3 = theme.sidebar,
		LayoutOrder = props.layoutOrder,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = theme.padding,
		}),

		BorderRadius = React.createElement("UICorner", {
			CornerRadius = theme.corner,
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.padding,
			PaddingRight = theme.padding,
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
		}),

		LineNumbers = React.createElement("TextLabel", {
			LayoutOrder = nextLayoutOrder(),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = getLineNumbers(source),
			TextSize = theme.textSize,
			LineHeight = 1,
			BackgroundTransparency = 1,
			Font = Enum.Font.RobotoMono,
			TextColor3 = theme.textFaded,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),

		SourceCode = React.createElement(SelectableTextLabel, {
			RichText = true,
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = source,
			TextColor3 = sourceColor,
			TextSize = theme.textSize,
			TextWrapped = false,
			LineHeight = 1,
			Font = Enum.Font.RobotoMono,
		}),
	})
end

return CodeBlock
