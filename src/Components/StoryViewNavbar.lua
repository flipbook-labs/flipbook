local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local assets = require(flipbook.assets)
local hook = require(flipbook.hook)
local Navbar = require(flipbook.Components.Navbar)
local Button = require(flipbook.Components.Button)
local Sprite = require(flipbook.Components.Sprite)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
}

local function NavbarRoot(props: Props, hooks: any)
	local theme = useTheme(hooks)

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
						Font = theme.headerFont,
						Size = UDim2.fromScale(0, 0),
						Text = "Canvas",
						TextColor3 = theme.text,
						TextSize = theme.headerTextSize,
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
						Font = theme.font,
						Size = UDim2.fromScale(0, 0),
						Text = "Documentation",
						TextColor3 = theme.textFaded,
						TextSize = theme.textSize,
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
					Icon = e(Sprite, {
						image = assets.Magnify,
						color = theme.textFaded,
						size = UDim2.fromOffset(24, 24),
					}),
				}),

				Minify = e(Navbar.Item, {
					active = false,
					layoutOrder = 2,
					onClick = function() end,
					padding = { x = UDim.new(0, 6), y = UDim.new(0, 10) },
				}, {
					Icon = e(Sprite, {
						image = assets.Minify,
						color = theme.textFaded,
						size = UDim2.fromOffset(24, 24),
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
						Font = theme.font,
						Size = UDim2.fromScale(0, 0),
						Text = "View Code",
						TextColor3 = theme.textFaded,
						TextSize = theme.textSize,
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
						Font = theme.font,
						Size = UDim2.fromScale(0, 0),
						Text = "Preview in Viewport",
						TextColor3 = theme.textFaded,
						TextSize = theme.textSize,
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
