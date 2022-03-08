local hook = require(script.Parent.Parent.Parent.Parent.hook)
local Llama = require(script.Parent.Parent.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local useTheme = require(script.Parent.Parent.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

type Props = {
	node: types.Node,
	onActivated: (types.Node) -> (),
}

local function StorybookDetails(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("ImageButton", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 32),
		[Roact.Event.Activated] = props.onActivated,
	}, {
		UIPadding = e("UIPadding", {
			PaddingLeft = styles.PADDING,
		}),

		Name = e(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Font = Enum.Font.GothamBlack,
				Position = UDim2.new(0, 55, 0.5, 0),
				Text = props.node.name,
				TextColor3 = theme.storybookEntry,
				TextSize = 14,
			})
		),

		Underline = e("Frame", {
			Size = UDim2.new(1, 0, 0, 2),
			BorderSizePixel = 0,
			BackgroundColor3 = theme.storybookEntry,
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
		}),
	})
end

return hook(StorybookDetails)
