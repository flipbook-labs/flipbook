local flipbook = script:FindFirstAncestor("flipbook")

local DragHandle = require(flipbook.Panels.DragHandle)
local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)
local types = require(flipbook.Panels.types)

local defaultProps = {
	dragHandleSize = 8, -- px
	minSize = Vector2.new(0, 0),
	maxSize = Vector2.new(math.huge, math.huge),
}

export type Props = {
	initialSize: UDim2,
	layoutOrder: number?,
	dragHandles: { types.DragHandle }?,
	hoverIconX: string?,
	hoverIconY: string?,
	onResize: ((newSize: Vector2) -> ())?,
	children: any,
}

type InternalProps = Props & typeof(defaultProps)

local function ResizablePanel(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)

	local absoluteSize, setAbsoluteSize = React.useState(nil)

	local clampedAbsoluteSize = React.useMemo(function()
		return if absoluteSize
			then Vector2.new(
				math.clamp(absoluteSize.X, props.minSize.X, props.maxSize.X),
				math.clamp(absoluteSize.Y, props.minSize.Y, props.maxSize.Y)
			)
			else nil
	end, { absoluteSize })

	local isWidthResizable = React.useMemo(function()
		if props.dragHandles then
			return Sift.Array.includes(props.dragHandles, "Left") or Sift.Array.includes(props.dragHandles, "Right")
		end
		return nil
	end, { props.dragHandles })

	local isHeightResizable = React.useMemo(function()
		if props.dragHandles then
			return Sift.Array.includes(props.dragHandles, "Top") or Sift.Array.includes(props.dragHandles, "Bottom")
		end
		return nil
	end, { props.dragHandles })

	local width = React.useMemo(function()
		return if clampedAbsoluteSize and isWidthResizable
			then UDim.new(0, clampedAbsoluteSize.X)
			else props.initialSize.Width
	end, { clampedAbsoluteSize })

	local height = React.useMemo(function()
		return if clampedAbsoluteSize and isHeightResizable
			then UDim.new(0, clampedAbsoluteSize.Y)
			else props.initialSize.Height
	end, { clampedAbsoluteSize, props.initialSize })

	local onAbsoluteSizeChanged = React.useCallback(function(rbx: Frame)
		setAbsoluteSize(rbx.AbsoluteSize)
	end, {})

	local onHandleDragged = React.useCallback(function(handle: types.DragHandle, delta: Vector2)
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

	React.useEffect(function()
		if clampedAbsoluteSize and props.onResize then
			props.onResize(clampedAbsoluteSize)
		end
	end, { clampedAbsoluteSize })

	local dragHandles = {}
	if props.dragHandles then
		for _, handle in props.dragHandles do
			dragHandles[handle] = React.createElement(DragHandle, {
				handle = handle,
				hoverIconX = props.hoverIconX,
				hoverIconY = props.hoverIconY,
				onDrag = function(delta: Vector2)
					onHandleDragged(handle, delta)
				end,
				onDragEnd = function()
					setAbsoluteSize(clampedAbsoluteSize)
				end,
			})
		end
	end

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(width, height),
		BackgroundTransparency = 1,
		[React.Change.AbsoluteSize] = onAbsoluteSizeChanged,
	}, {
		DragHandles = React.createElement(React.Fragment, nil, dragHandles),

		Children = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, props.children),
	})
end

return ResizablePanel
