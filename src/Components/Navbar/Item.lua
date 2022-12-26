local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local constants = require(flipbook.constants)
local useTheme = require(flipbook.Hooks.useTheme)

local e = React.createElement

type Props = {
	active: boolean,
	layoutOrder: number,
	onClick: () -> (),
	padding: { x: number, y: number }?,
	children: any,
}

local function Item(props: Props)
	local theme = useTheme()

	local hover, setHover = React.useState(false)
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

		[ReactRoblox.Event.Activated] = props.onClick,
		[ReactRoblox.Event.MouseEnter] = function()
			setHover(true)
		end,
		[ReactRoblox.Event.MouseLeave] = function()
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

		Children = React.createFragment(props.children or {}),
	})
end

return Item
