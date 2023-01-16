local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local useTheme = require(flipbook.Hooks.useTheme)

export type Props = {
	initialState: boolean,
	onStateChange: ((newState: boolean) -> ())?,
}

local function Checkbox(props: Props)
	local theme = useTheme()
	local isChecked, setIsChecked = React.useState(props.initialState)

	local toggle = React.useCallback(function()
		local newValue = not isChecked

		if props.onStateChange then
			props.onStateChange(newValue)
		end

		setIsChecked(newValue)
	end, { isChecked })

	return React.createElement("ImageButton", {
		BackgroundColor3 = theme.button,
		Size = UDim2.fromOffset(theme.textSize, theme.textSize) + UDim2.new(theme.padding, theme.padding),
		[React.Event.Activated] = toggle,
	}, {
		Layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Corner = React.createElement("UICorner", {
			CornerRadius = theme.paddingSmall,
		}),

		Border = React.createElement("UIStroke", {
			Color = theme.buttonText,
			Transparency = 0.4,
			Thickness = 2,
		}),

		Check = isChecked and React.createElement("TextLabel", {
			Text = "✔️",
			TextSize = theme.textSize,
			Font = theme.headerFont,
			TextColor3 = theme.buttonText,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
		}),
	})
end

return Checkbox
