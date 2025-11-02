local Foundation = require("@rbxpkg/Foundation")
local Highlighter = require("@pkg/Highlighter")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local SelectableTextLabel = require("@root/Common/SelectableTextLabel")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useMemo = React.useMemo
local useTokens = Foundation.Hooks.useTokens

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
	local tokens = useTokens()

	local sourceColor = useMemo(function()
		return if props.sourceColor then props.sourceColor else tokens.Color.Content.Default.Color3
	end, { props.sourceColor, tokens } :: { unknown })

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

	return React.createElement(Foundation.View, {
		tag = "size-full-0 auto-y bg-surface-200 gap-medium row radius-medium padding-medium",
		LayoutOrder = props.layoutOrder,
	}, {
		LineNumbers = React.createElement("TextLabel", {
			LayoutOrder = nextLayoutOrder(),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = getLineNumbers(source),
			TextSize = tokens.Typography.BodyMedium.FontSize,
			LineHeight = 1,
			BackgroundTransparency = 1,
			Font = Enum.Font.RobotoMono,
			TextColor3 = tokens.Color.Content.Muted.Color3,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),

		SourceCodeWrapper = React.createElement(Foundation.ScrollView, {
			tag = "size-full-0 auto-y shrink",
			scroll = {
				AutomaticSize = Enum.AutomaticSize.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.XY,
				CanvasSize = UDim2.fromScale(0, 0),
				ScrollingDirection = Enum.ScrollingDirection.X,
				HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
			},
			LayoutOrder = nextLayoutOrder(),
		}, {
			SourceCode = React.createElement(SelectableTextLabel, {
				RichText = true,
				LayoutOrder = nextLayoutOrder(),
				AutomaticSize = Enum.AutomaticSize.XY,
				Text = source,
				TextColor3 = sourceColor,
				TextSize = tokens.Typography.BodyMedium.FontSize,
				TextWrapped = false,
				LineHeight = 1,
				Font = Enum.Font.RobotoMono,
			}),
		}),
	})
end

return CodeBlock
