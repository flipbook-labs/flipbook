local hook = require(script.Parent.Parent.Parent.Parent.hook)
local Icon = require(script.Parent.Parent.Parent.Icon)
local Llama = require(script.Parent.Parent.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Parent.Parent.Packages.Roact)
local RoactSpring = require(script.Parent.Parent.Parent.Parent.Packages.RoactSpring)
local styles = require(script.Parent.Parent.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local useTheme = require(script.Parent.Parent.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

type Props = {
	active: boolean,
	indentLevel: number?,
	node: types.Node,
	onActivated: (types.Node) -> (),
}

local function deriveIconSize(icon: string): UDim2
	if icon == "folder" then
		return UDim2.fromOffset(14, 10)
	elseif icon == "story" then
		return UDim2.fromOffset(14, 14)
	end
end

local function NodeDetails(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local hovered, setHovered = hooks.useState(false)
	local style = RoactSpring.useSpring(hooks, {
		transparency = if hovered or props.active then 0 else 1,
		background = if props.active then 0 else 1,
		config = {
			mass = 1,
			friction = 12,
			clamp = true,
		},
	})

	return e("ImageButton", {
		AutoButtonColor = false,
		BackgroundColor3 = style.background:map(function(value)
			return theme.entry.selectedBackground:Lerp(theme.entry.background, value)
		end),
		BackgroundTransparency = style.transparency,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 32),
		[Roact.Event.Activated] = props.onActivated,
		[Roact.Event.MouseEnter] = function()
			setHovered(true)
		end,
		[Roact.Event.MouseLeave] = function()
			setHovered(false)
		end,
	}, {
		UIPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, styles.PADDING.Offset * props.indentLevel + 1),
		}),

		Icon = e(Icon, {
			anchorPoint = Vector2.new(0, 0.5),
			color = theme.icons[props.node.icon],
			icon = props.node.icon,
			position = UDim2.new(0, 30, 0.5, 0),
			size = deriveIconSize(props.node.icon),
		}),

		Name = e(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 55, 0.5, 0),
				Text = props.node.name,
				TextColor3 = style.background:map(function(value)
					return theme.entry.selectedText:Lerp(theme.entry.text, value)
				end),
				TextSize = 12,
			})
		),
	})
end

return hook(NodeDetails)
