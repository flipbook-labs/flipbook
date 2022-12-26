local flipbook = script:FindFirstAncestor("flipbook")

local Sift = require(flipbook.Packages.Sift)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local DragHandle = require(flipbook.Components.DragHandle)
local types = require(script.Parent.Parent.types)

local defaultProps = {
	hoverIcon = "",
	dragHandleSize = 8, -- px
	minSize = Vector2.new(0, 0),
	maxSize = Vector2.new(math.huge, math.huge),
}

export type Props = typeof(defaultProps) & {
	initialSize: UDim2,
	layoutOrder: number?,
	dragHandles: { types.DragHandle }?,
	onResize: ((newSize: Vector2) -> ())?,
}

local function ResizablePanel(props: Props, hooks: any)
	props = Sift.Dictionary.merge(defaultProps, props)

	local absoluteSize, setAbsoluteSize = hooks.useState(nil)

	local clampedAbsoluteSize = if absoluteSize
		then Vector2.new(
			math.clamp(absoluteSize.X, props.minSize.X, props.maxSize.X),
			math.clamp(absoluteSize.Y, props.minSize.Y, props.maxSize.Y)
		)
		else nil

	local onAbsoluteSizeChanged = hooks.useCallback(function(rbx: Frame)
		setAbsoluteSize(rbx.AbsoluteSize)
	end, {})

	local onHandleDragged = hooks.useCallback(function(handle: types.DragHandle, delta: Vector2)
		setAbsoluteSize(function(prev: Vector2)
			local x = prev.X + delta.X
			local y = prev.Y - delta.Y

			if handle == "Top" or handle == "Bottom" then
				x = prev.X
			elseif handle == "Right" or handle == "Left" then
				y = prev.Y
			end

			return Vector2.new(x, y)
		end)
	end, { props.minSize, props.maxSize })

	hooks.useEffect(function()
		if clampedAbsoluteSize and props.onResize then
			props.onResize(clampedAbsoluteSize)
		end
	end, { clampedAbsoluteSize })

	local dragHandles = {}
	if props.dragHandles then
		for _, handle in props.dragHandles do
			dragHandles[handle] = Roact.createElement(DragHandle, {
				handle = handle,
				hoverIcon = props.hoverIcon,
				onDrag = function(delta: Vector2)
					onHandleDragged(handle, delta)
				end,
				onDragEnd = function()
					setAbsoluteSize(clampedAbsoluteSize)
				end,
			})
		end
	end

	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = if clampedAbsoluteSize
			then UDim2.fromOffset(clampedAbsoluteSize.X, clampedAbsoluteSize.Y)
			else props.initialSize,
		BackgroundTransparency = 1,
		[Roact.Change.AbsoluteSize] = onAbsoluteSizeChanged,
	}, {
		DragHandles = Roact.createFragment(dragHandles),

		Children = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, (props :: any)[Roact.Children]),
	})
end

return hook(ResizablePanel)
