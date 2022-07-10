local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local constants = require(flipbook.constants)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	active: boolean,
	layoutOrder: number,
	onClick: () -> (),
	padding: { x: number, y: number }?,
}

local function Item(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local hover, setHover = hooks.useState(false)
	local styles = RoactSpring.useSpring(hooks, {
		alpha = if not props.active and hover then 0 else 1,
		config = constants.SPRING_CONFIG,
	})

	return e("TextButton", {
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = theme.button,
		BackgroundTransparency = styles.alpha,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(0, 0),
		Text = "",

		[Roact.Event.Activated] = props.onClick,
		[Roact.Event.MouseEnter] = function()
			setHover(true)
		end,
		[Roact.Event.MouseLeave] = function()
			setHover(false)
		end,
	}, {
		UIPadding = if props.padding
			then e("UIPadding", {
				PaddingBottom = props.padding.y,
				PaddingLeft = props.padding.x,
				PaddingRight = props.padding.x,
				PaddingTop = props.padding.y,
			})
			else nil,

		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		Children = Roact.createFragment(props[Roact.Children] or {}),
	})
end

return hook(Item)
