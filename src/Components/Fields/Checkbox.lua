local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local useTheme = require(flipbook.Hooks.useTheme)
local hook = require(flipbook.hook)

export type Props = {
	initialState: boolean,
	onStateChange: ((newState: boolean) -> ())?,
}

local function Checkbox(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local isChecked, setIsChecked = hooks.useState(props.initialState)

	local toggle = hooks.useCallback(function()
		local newValue = not isChecked

		if props.onStateChange then
			props.onStateChange(newValue)
		end

		setIsChecked(newValue)
	end, { isChecked })

	return Roact.createElement("ImageButton", {
		BackgroundColor3 = theme.button,
		Size = UDim2.fromOffset(theme.textSize, theme.textSize) + UDim2.new(theme.padding, theme.padding),
		[Roact.Event.Activated] = toggle,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Corner = Roact.createElement("UICorner", {
			CornerRadius = theme.paddingSmall,
		}),

		Border = Roact.createElement("UIStroke", {
			Color = theme.buttonText,
			Transparency = 0.4,
			Thickness = 2,
		}),

		Check = isChecked and Roact.createElement("TextLabel", {
			Text = "✔️",
			TextSize = theme.textSize,
			Font = theme.headerFont,
			TextColor3 = theme.buttonText,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
		}),
	})
end

return hook(Checkbox)
