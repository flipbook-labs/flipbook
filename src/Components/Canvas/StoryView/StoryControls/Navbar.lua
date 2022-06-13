local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Navbar = require(flipbook.Components.Generic.Navbar)
local Roact = require(flipbook.Packages.Roact)
local useTailwind = require(flipbook.Hooks.useTailwind)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
}

local function NavbarRoot(props: Props)
	return e(Navbar.Element, {
		height = 55,
		layoutOrder = props.layoutOrder,
		topDivider = true,
	}, {
		Content = e(Navbar.Items, {
			layoutOrder = 1,
			padding = UDim.new(0, 12),
		}, {
			Pages = e(Navbar.Items, {
				layoutOrder = 1,
				padding = UDim.new(0, 0),
			}, {
				Controls = e(Navbar.Item, {
					active = true,
					layoutOrder = 1,
					onClick = function() end,
					padding = { x = UDim.new(0, 10), y = UDim.new(0, 10) },
				}, {
					Text = e("TextLabel", {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamMedium,
						Size = UDim2.fromScale(0, 0),
						Text = "Controls",
						TextColor3 = useTailwind("gray-800"),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),

				Story = e(Navbar.Item, {
					active = false,
					layoutOrder = 2,
					onClick = function() end,
					padding = { x = UDim.new(0, 10), y = UDim.new(0, 10) },
				}, {
					Text = e("TextLabel", {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamMedium,
						Size = UDim2.fromScale(0, 0),
						Text = "Story",
						TextColor3 = useTailwind("gray-600"),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),
			}),
		}),
	})
end

return hook(NavbarRoot)
