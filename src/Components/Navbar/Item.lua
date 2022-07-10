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
		BackgroundColor3 = theme.divider,
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
		UIPadding = e("UIPadding", {
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
			PaddingRight = theme.padding,
			PaddingTop = theme.padding,
		}),

		UICorner = e("UICorner", {
			CornerRadius = theme.corner,
		}),

		Children = Roact.createFragment(props[Roact.Children] or {}),
	})
end

return hook(Item)
