local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	name = "MapStory",
	storyRoots = {
		script.Parent,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
	mapStory = function(Story)
		return function(props: { [string]: any })
			return React.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 16),
					PaddingRight = UDim.new(0, 16),
					PaddingBottom = UDim.new(0, 16),
					PaddingLeft = UDim.new(0, 16),
				}),
				Story = React.createElement(Story, props),
			})
		end
	end,
}
