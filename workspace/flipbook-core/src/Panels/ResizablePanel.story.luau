local React = require("@pkg/React")
local ResizablePanel = require("./ResizablePanel")
local types = require("./types")

local controls = {
	minWidth = 200,
	maxWidth = 500,
	minHeight = 200,
	maxHeight = 500,
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	story = function(props: Props)
		local dragHandles: { types.DragHandle } = { "Right", "Bottom" }

		return React.createElement(ResizablePanel, {
			initialSize = UDim2.fromOffset(props.controls.maxWidth - props.controls.minWidth, 300),
			maxSize = Vector2.new(props.controls.maxWidth, props.controls.maxHeight),
			minSize = Vector2.new(props.controls.minWidth, props.controls.minHeight),
			dragHandles = dragHandles,
		}, {
			Content = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
			}),
		})
	end,
}
