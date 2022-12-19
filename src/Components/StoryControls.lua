local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local Navbar = require(flipbook.Components.Navbar)
local useTheme = require(flipbook.Hooks.useTheme)
local types = require(flipbook.types)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
	controls: { types.StoryControl },
}

local function StoryControls(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local controls = {}
	controls.Layout = e("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = theme.padding,
	})
	for index, control in props.controls do
		controls[control.name] = e("Frame", {}, {
			Name = e("TextLabel", {
				LayoutOrder = index,
				Text = control.name,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.font,
				TextColor3 = theme.text,
				TextSize = theme.headerTextSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),

			Option = e("TextLabel"),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Navbar = e(Navbar.Element, {
			height = 55,
			layoutOrder = props.layoutOrder,
			topDivider = true,
		}, {
			Content = e(Navbar.Items, {
				layoutOrder = 1,
				padding = theme.padding,
			}, {
				Controls = e(Navbar.Item, {
					active = true,
					layoutOrder = 1,
					onClick = function() end,
					padding = { x = theme.padding, y = theme.padding },
				}, {
					Layout = e("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = theme.padding,
					}),

					Title = e("TextLabel", {
						LayoutOrder = 1,
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

					Controls = e("Frame", {
						LayoutOrder = 2,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
					}, controls),
				}),
			}),
		}),
	})
end

return hook(StoryControls)
