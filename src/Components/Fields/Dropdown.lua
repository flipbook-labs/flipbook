local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local useTheme = require(flipbook.Hooks.useTheme)
local hook = require(flipbook.hook)

export type Props = {
	placeholder: string?,
	default: string?,
	options: { string },
	onOptionChange: ((newOption: string?) -> ())?,
}

local function Dropdown(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local isExpanded, setIsExpanded = hooks.useState(false)
	local selectedOption, setSelectedOption = hooks.useState(props.default)

	local options = {}
	for index, option in props.options do
		options["Option" .. index] = Roact.createElement("TextButton", {
			LayoutOrder = index,
			Text = option,
			Font = theme.font,
			TextSize = theme.textSize,
			TextColor3 = theme.buttonText,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = theme.buttonText,
			BackgroundTransparency = if index % 2 ~= 0 then 1 else 0.9,
			[Roact.Event.Activated] = function()
				setSelectedOption(option)
				setIsExpanded(false)
			end,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = theme.padding,
				PaddingRight = theme.padding,
				PaddingBottom = theme.padding,
				PaddingLeft = theme.padding,
			}),
		})
	end

	local maxHeight = theme.textSize + (theme.padding.Offset * 2)

	return Roact.createElement("TextButton", {
		Text = if selectedOption then selectedOption else props.placeholder,
		Font = theme.font,
		TextSize = theme.textSize,
		TextColor3 = theme.buttonText,
		BackgroundColor3 = theme.button,
		Size = UDim2.fromOffset(0, maxHeight),
		AutomaticSize = Enum.AutomaticSize.X,
		[Roact.Event.Activated] = function()
			setIsExpanded(not isExpanded)
		end,
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = theme.paddingSmall,
		}),

		Border = Roact.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = theme.buttonText,
			Transparency = 0.4,
			Thickness = 2,
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = theme.padding,
			PaddingRight = theme.padding,
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
		}),

		Options = isExpanded and Roact.createElement("Frame", {
			Position = UDim2.fromScale(0, 1),
			BackgroundColor3 = theme.button,
			AutomaticSize = Enum.AutomaticSize.XY,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),

			Corner = Roact.createElement("UICorner", {
				CornerRadius = theme.paddingSmall,
			}),

			Border = Roact.createElement("UIStroke", {
				Color = theme.buttonText,
				Transparency = 0.4,
				Thickness = 2,
			}),

			Options = Roact.createFragment(options),
		}),
	})
end

return hook(Dropdown)
