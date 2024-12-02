local React = require("@pkg/react")
local useTheme = require("@root/Common/useTheme")

export type Props = {
	placeholder: string?,
	default: string?,
	options: { string },
	onOptionChange: ((newOption: string?) -> ())?,
}

local function Dropdown(props: Props)
	local theme = useTheme()
	local isExpanded, setIsExpanded = React.useState(false)
	local selectedOption, setSelectedOption = React.useState(props.default)

	local options: { [string]: React.Node } = {}
	for index, option in props.options do
		options["Option" .. index] = React.createElement("TextButton", {
			LayoutOrder = index,
			Text = tostring(option),
			Font = theme.buttonFont,
			TextSize = theme.buttonTextSize,
			TextColor3 = theme.buttonText,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = theme.buttonText,
			BackgroundTransparency = if index % 2 ~= 0 then 1 else 0.9,
			[React.Event.Activated] = function()
				setSelectedOption(option)
				setIsExpanded(false)

				if props.onOptionChange then
					props.onOptionChange(option)
				end
			end,
		}, {
			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.paddingSmall,
				PaddingRight = theme.padding,
				PaddingBottom = theme.paddingSmall,
				PaddingLeft = theme.padding,
			}),
		})
	end

	local maxHeight = theme.buttonTextSize + (theme.paddingSmall.Offset * 2)

	return React.createElement("TextButton", {
		Text = tostring(if selectedOption then selectedOption else props.placeholder),
		Font = theme.buttonFont,
		TextSize = theme.buttonTextSize,
		TextColor3 = theme.buttonText,
		BackgroundColor3 = theme.button,
		Size = UDim2.fromOffset(0, maxHeight),
		AutomaticSize = Enum.AutomaticSize.X,
		[React.Event.Activated] = function()
			setIsExpanded(not isExpanded)
		end,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = theme.corner,
		}),

		Border = React.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = theme.buttonText,
			Transparency = 0.6,
			Thickness = 1,
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.paddingSmall,
			PaddingRight = theme.padding,
			PaddingBottom = theme.paddingSmall,
			PaddingLeft = theme.padding,
		}),

		Options = isExpanded and React.createElement("Frame", {
			Position = UDim2.fromScale(0, 1),
			BackgroundColor3 = theme.button,
			AutomaticSize = Enum.AutomaticSize.XY,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),

			Corner = React.createElement("UICorner", {
				CornerRadius = theme.corner,
			}),

			Border = React.createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = theme.buttonText,
				Transparency = 0.6,
				Thickness = 1,
			}),

			Options = React.createElement(React.Fragment, nil, options),
		}),
	})
end

return Dropdown
