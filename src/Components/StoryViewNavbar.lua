local flipbook = script:FindFirstAncestor("flipbook")

local assets = require(flipbook.assets)
local hook = require(flipbook.hook)
local Navbar = require(flipbook.Components.Navbar)
local Button = require(flipbook.Components.Button)
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
	}, {
		LeftNav = e(Navbar.Items, {
			layoutOrder = 1,
			padding = UDim.new(0, 12),
		}, {
			Pages = e(Navbar.Items, {
				layoutOrder = 1,
				padding = UDim.new(0, 0),
			}, {
				Canvas = e(Navbar.Item, {
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
						Text = "Canvas",
						TextColor3 = useTailwind("gray-800"),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),

				Documentation = e(Navbar.Item, {
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
						Text = "Documentation",
						TextColor3 = useTailwind("gray-600"),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),
			}),

			PageSplit = e(Navbar.Divider, {
				layoutOrder = 2,
			}),

			Zoom = e(Navbar.Items, {
				layoutOrder = 3,
				padding = UDim.new(0, 0),
			}, {
				Magnify = e(Navbar.Item, {
					active = false,
					layoutOrder = 1,
					onClick = function() end,
					padding = { x = UDim.new(0, 6), y = UDim.new(0, 10) },
				}, {
					Icon = e("ImageLabel", {
						BackgroundTransparency = 1,
						Image = assets.Magnify,
						ImageColor3 = useTailwind("gray-600"),
						Size = UDim2.fromOffset(24, 24),
					}),
				}),

				Minify = e(Navbar.Item, {
					active = false,
					layoutOrder = 2,
					onClick = function() end,
					padding = { x = UDim.new(0, 6), y = UDim.new(0, 10) },
				}, {
					Icon = e("ImageLabel", {
						BackgroundTransparency = 1,
						Image = assets.Minify,
						ImageColor3 = useTailwind("gray-600"),
						Size = UDim2.fromOffset(24, 24),
					}),
				}),
			}),

			ZoomSplit = e(Navbar.Divider, {
				layoutOrder = 3,
			}),

			Mount = e(Navbar.Items, {
				layoutOrder = 4,
				padding = UDim.new(0, 0),
			}, {
				ViewCode = e(Navbar.Item, {
					active = false,
					layoutOrder = 1,
					onClick = function() end,
					padding = { x = UDim.new(0, 10), y = UDim.new(0, 10) },
				}, {
					Text = e("TextLabel", {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamMedium,
						Size = UDim2.fromScale(0, 0),
						Text = "View Code",
						TextColor3 = useTailwind("gray-800"),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),

				Mount = e(Navbar.Item, {
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
						Text = "Preview in Viewport",
						TextColor3 = useTailwind("gray-800"),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),
			}),
		}),

		Help = e(Button, {
			text = "Help",
			anchorPoint = Vector2.new(1, 0),
			position = UDim2.new(1, 0, 0, 0),
		}),
	})
end

return hook(NavbarRoot)
