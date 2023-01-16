local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ScrollingFrame = require(script.Parent.ScrollingFrame)

local controls = {
	numItems = 10,
	useGradient = true,
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	story = function(props: Props)
		local children = {}

		children.Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 16),
		})

		for i = 1, props.controls.numItems do
			children["Box" .. i] = React.createElement("Frame", {
				LayoutOrder = i,
				Size = UDim2.fromOffset(100, 100),
				BackgroundColor3 = if props.controls.useGradient
					then Color3.fromRGB(0, 255 / i, 0)
					else Color3.fromRGB(0, 255, 0),
			})
		end

		return React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 200),
			BackgroundTransparency = 1,
		}, {
			ScrollingFrame = React.createElement(ScrollingFrame, {}, children),
		})
	end,
}
