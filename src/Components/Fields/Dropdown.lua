local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local useTheme = require(flipbook.Hooks.useTheme)

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

	local options = {}
	for index, option in props.options do
		options["Option" .. index] = React.createElement("TextButton", {
			LayoutOrder = index,
			Text = option,
			Font = theme.font,
			TextSize = theme.textSize,
			TextColor3 = theme.buttonText,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = theme.buttonText,
			BackgroundTransparency = if index % 2 ~= 0 then 1 else 0.9,
			[ReactRoblox.Event.Activated] = function()
				setSelectedOption(option)
				setIsExpanded(false)
			end,
		}, {
			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.padding,
				PaddingRight = theme.padding,
				PaddingBottom = theme.padding,
				PaddingLeft = theme.padding,
			}),
		})
	end

	local maxHeight = theme.textSize + (theme.padding.Offset * 2)

	return React.createElement("TextButton", {
		Text = if selectedOption then selectedOption else props.placeholder,
		Font = theme.font,
		TextSize = theme.textSize,
		TextColor3 = theme.buttonText,
		BackgroundColor3 = theme.button,
		Size = UDim2.fromOffset(0, maxHeight),
		AutomaticSize = Enum.AutomaticSize.X,
		[ReactRoblox.Event.Activated] = function()
			setIsExpanded(not isExpanded)
		end,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = theme.paddingSmall,
		}),

		Border = React.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = theme.buttonText,
			Transparency = 0.4,
			Thickness = 2,
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.padding,
			PaddingRight = theme.padding,
			PaddingBottom = theme.padding,
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
				CornerRadius = theme.paddingSmall,
			}),

			Border = React.createElement("UIStroke", {
				Color = theme.buttonText,
				Transparency = 0.4,
				Thickness = 2,
			}),

			Options = React.createFragment(options),
		}),
	})
end

return Dropdown
