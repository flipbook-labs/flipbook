local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local Navbar = require(flipbook.Components.Navbar)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
}

local function StoryControls(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
	}, {
		Navbar = e(Navbar.Element, {
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
							Font = theme.headerFont,
							Size = UDim2.fromScale(0, 0),
							Text = "Controls",
							TextColor3 = theme.text,
							TextSize = theme.headerTextSize,
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
							Font = theme.font,
							Size = UDim2.fromScale(0, 0),
							Text = "Story",
							TextColor3 = theme.textFaded,
							TextSize = theme.textSize,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
						}),
					}),
				}),
			}),
		}),
	})
end

return hook(StoryControls)
