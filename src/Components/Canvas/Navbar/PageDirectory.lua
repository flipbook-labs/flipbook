local flipbook = script:FindFirstAncestor("flipbook")

local ButtonLink = require(flipbook.Components.Generic.ButtonLink)
local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)

local e = Roact.createElement

local function PageDirectory()
	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0, 1),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Canvas = e(ButtonLink, {
			active = true,
			layoutOrder = 0,
			onClick = function() end,
			text = "Canvas",
		}),

		Documentation = e(ButtonLink, {
			active = false,
			layoutOrder = 1,
			onClick = function() end,
			text = "Documentation",
		}),
	})
end

return hook(PageDirectory)
