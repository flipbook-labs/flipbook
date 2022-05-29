local hook = require(script.Parent.Parent.Parent.Parent.hook)
local Icon = require(script.Parent.Parent.Parent.Icon)
local Llama = require(script.Parent.Parent.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local useTheme = require(script.Parent.Parent.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

type Props = {
	expanded: boolean,
	hasChildren: boolean,
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
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		UIPadding = e("UIPadding", {
			PaddingLeft = styles.PADDING,
		}),

		Name = e(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Font = Enum.Font.GothamBlack,
				Position = UDim2.new(0, 20, 0.5, 0),
				Text = props.node.name:gsub(".", "%1 "):sub(1, -2),
				TextColor3 = theme.strokeSecondary,
				TextSize = 16,
			})
		),

		ArrowWrapper = props.hasChildren and e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(16, 16),
		}, {
			Arrow = e(Icon, {
				anchorPoint = Vector2.new(0.5, 0.5),
				color = theme.strokeSecondary,
				icon = "chevron-right",
				position = UDim2.fromScale(0.5, 0.5),
				rotation = if props.expanded then 90 else 0,
				size = 6,
			}),
		}),
	})
end

return hook(StorybookDetails)
