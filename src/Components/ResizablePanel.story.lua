local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local ResizablePanel = require(script.Parent.ResizablePanel)

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
	story = function(props)
		return Roact.createElement(ResizablePanel, {
			initialSize = UDim2.fromOffset(props.controls.maxWidth - props.controls.minWidth, 300),
			maxSize = Vector2.new(props.controls.maxWidth, props.controls.maxHeight),
			minSize = Vector2.new(props.controls.minWidth, props.controls.minHeight),
			dragHandles = { "Right", "Bottom" },
		}, {
			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
			}),
		})
	end,
}
