local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local ScrollingFrame = require("./ScrollingFrame")

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
		local children: { [string]: React.Node } = {}

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

		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			Wrapper = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 200),
				BackgroundTransparency = 1,
			}, {
				ScrollingFrame = React.createElement(ScrollingFrame, {}, children),
			}),
		})
	end,
}
