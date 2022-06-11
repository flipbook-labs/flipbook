local constants = require(script.Parent.Parent.Parent.Parent.constants)
local hook = require(script.Parent.Parent.Parent.Parent.hook)
local Icon = require(script.Parent.Parent.Parent.Icon)
local Llama = require(script.Parent.Parent.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Parent.Parent.Packages.Roact)
local RoactSpring = require(script.Parent.Parent.Parent.Parent.Packages.RoactSpring)
local styles = require(script.Parent.Parent.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local useTheme = require(script.Parent.Parent.Parent.Parent.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	active: boolean,
	expanded: boolean,
	hasChildren: boolean,
	indentLevel: number?,
	node: types.Node,
	onActivated: (types.Node) -> (),
}

local function deriveIconSize(icon: string): UDim2?
	if icon == "folder" then
		return UDim2.fromOffset(14, 10)
	elseif icon == "story" then
		return UDim2.fromOffset(14, 14)
	end
	return nil
end

local function NodeDetails(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local hovered, setHovered = hooks.useState(false)
	local style = RoactSpring.useSpring(hooks, {
		transparency = if hovered or props.active then 0 else 1,
		background = if props.active then 0 else 1,
		config = constants.SPRING_CONFIG,
	})

	return e("ImageButton", {
		AutoButtonColor = false,
		BackgroundColor3 = style.background:map(function(value)
			return theme.brand:Lerp(theme.canvas, value)
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
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		UIPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, styles.PADDING.Offset * props.indentLevel + 1),
		}),

		Icon = e(Icon, {
			anchorPoint = Vector2.new(0, 0.5),
			color = if props.node.icon == "folder" then theme.brand else theme.component,
			icon = props.node.icon,
			position = UDim2.new(0, 30, 0.5, 0),
			size = if props.node.icon then deriveIconSize(props.node.icon) else nil,
		}),

		Name = e(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 55, 0.5, 0),
				Text = if props.node.name:match(constants.STORY_NAME_PATTERN)
					then props.node.name:sub(1, #props.node.name - 6)
					else props.node.name,
				TextColor3 = style.background:map(function(value)
					return Color3.fromHex("FFFFFF"):Lerp(theme.text, value)
				end),
				TextSize = 12,
			})
		),

		ArrowWrapper = props.hasChildren and e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0.5, 0),
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

return hook(NodeDetails)
