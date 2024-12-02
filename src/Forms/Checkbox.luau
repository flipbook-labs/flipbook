local React = require("@pkg/react")
local useTheme = require("@root/Common/useTheme")

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
		Size = UDim2.fromOffset(theme.buttonTextSize, theme.buttonTextSize) + UDim2.new(theme.padding, theme.padding),
		[React.Event.Activated] = toggle,
	}, {
		Layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Corner = React.createElement("UICorner", {
			CornerRadius = theme.corner,
		}),

		Border = React.createElement("UIStroke", {
			Color = theme.buttonText,
			Transparency = 0.6,
			Thickness = 1,
		}),

		Check = isChecked and React.createElement("TextLabel", {
			Text = "✔️",
			TextSize = theme.buttonTextSize,
			Font = theme.buttonFont,
			TextColor3 = theme.buttonText,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
		}),
	})
end

return Checkbox
