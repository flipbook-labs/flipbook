local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local ScrollingFrame = require(script.Parent.ScrollingFrame)

return {
	story = function()
		local children = {}

		children.Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 16),
		})

		for i = 1, 10 do
			children["Box" .. i] = Roact.createElement("Frame", {
				LayoutOrder = i,
				Size = UDim2.fromOffset(100, 100),
				BackgroundColor3 = Color3.fromRGB(0, 255 / i, 0),
			})
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 200),
			BackgroundTransparency = 1,
		}, {
			ScrollingFrame = Roact.createElement(ScrollingFrame, {}, children),
		})
	end,
}
