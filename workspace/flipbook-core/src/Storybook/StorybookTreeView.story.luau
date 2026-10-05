local React = require("@pkg/React")

local StorybookTreeView = require("./StorybookTreeView")

return {
	story = function()
		return React.createElement("Frame", {
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			StorybookTreeView = React.createElement(StorybookTreeView),
		})
	end,
}
