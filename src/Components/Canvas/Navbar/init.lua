local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local PageDirectory = require(script.PageDirectory)
local Roact = require(flipbook.Packages.Roact)
local useTailwind = require(flipbook.Hooks.useTailwind)
local VerticalDivider = require(script.VerticalDivider)

local e = Roact.createElement

local function Navbar()
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 55),
	}, {
		Divider = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = useTailwind("gray-300"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
		}),

		Container = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			LeftNavigation = e("Frame", {
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0, 1),
			}, {
				PageDirectory = e(PageDirectory),

				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 12),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				PageDivider = e(VerticalDivider, {
					layoutOrder = 1,
				}),
			}),

			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingTop = UDim.new(0, 10),
			}),
		}),
	})
end

return hook(Navbar)
