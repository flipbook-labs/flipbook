local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local styles = require(script.Parent.Parent.styles)
local Checkbox = require(script.Parent.Checkbox)

export type Props = {
	key: string,
	value: any,
	onValueChange: ((any) -> nil)?,
}

local function StoryControl(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local onSubmit = hooks.useCallback(function(rbx: TextBox, enterPressed: boolean)
		if props.onValueChange and enterPressed then
			props.onValueChange(rbx.Text)
		end
	end, {})

	local valueElement
	if typeof(props.value) == "boolean" then
		valueElement = Roact.createElement(Checkbox, {
			isChecked = props.value,
			onActivated = props.onValueChange,
		})
	else
		valueElement = Roact.createElement(
			"TextBox",
			Llama.Dictionary.join(styles.TextLabel, {
				LayoutOrder = 2,
				Text = props.value,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
				BackgroundTransparency = 0,
				[Roact.Event.FocusLost] = onSubmit,
			})
		)
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = styles.LARGE_PADDING,
		}),

		Key = Roact.createElement(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				LayoutOrder = 1,
				Text = props.key,
			})
		),

		Value = valueElement,
	})
end

return RoactHooks.new(Roact)(StoryControl)
