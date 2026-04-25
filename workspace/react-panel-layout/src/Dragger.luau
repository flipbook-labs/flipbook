local Foundation = require("@rbxpkg/Foundation")
local GroupContext = require("./GroupContext")
local React = require("@pkg/React")

local useCallback = React.useCallback
local useRef = React.useRef
local useState = React.useState
local useTokens = Foundation.Hooks.useTokens

local HITBOX_SIZE = 9
local VISUAL_SIZE = 3
local HOVER_ICON_X = "rbxasset://textures/StudioUIEditor/icon_resize2.png"
local HOVER_ICON_Y = "rbxasset://textures/StudioUIEditor/icon_resize4.png"

export type DraggerProps = {
	onDragStart: (() -> ())?,
	onDrag: (delta: Vector2) -> (),
	onDragEnd: (() -> ())?,
	LayoutOrder: number?,
}

local function Dragger(props: DraggerProps)
	local groupContext = GroupContext.use()
	local isHorizontal = if groupContext then groupContext.fillDirection == Enum.FillDirection.Horizontal else false

	local isHovered, setIsHovered = useState(false)
	local isDragging, setIsDragging = useState(false)
	local initialDragPosition = useRef(nil :: Vector2?)
	local tokens = useTokens()

	local onStateChanged = useCallback(
		function(newState)
			setIsHovered(newState == Foundation.Enums.ControlState.Hover)
		end :: Foundation.StateChangedCallback,
		{}
	)

	local onDragStart = useCallback(function(_rbx: UIDragDetector, inputPosition: Vector2)
		setIsDragging(true)
		initialDragPosition.current = inputPosition

		if props.onDragStart then
			props.onDragStart()
		end
	end, { props.onDragStart })

	local onDragContinue = useCallback(function(_rbx: UIDragDetector, inputPosition: Vector2)
		if initialDragPosition.current then
			local delta = inputPosition - initialDragPosition.current
			props.onDrag(delta)
		end
	end, { props.onDrag })

	local onDragEnd = useCallback(function(_rbx: UIDragDetector, _inputPosition: Vector2)
		setIsDragging(false)
		initialDragPosition.current = nil

		if props.onDragEnd then
			props.onDragEnd()
		end
	end, { props.onDragEnd })

	local cursorIcon = if isHorizontal then HOVER_ICON_X else HOVER_ICON_Y

	return React.createElement(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		Size = if isHorizontal then UDim2.new(0, HITBOX_SIZE, 1, 0) else UDim2.new(1, 0, 0, HITBOX_SIZE),
		onStateChanged = onStateChanged,
	}, {
		Visual = React.createElement(Foundation.View, {
			tag = {
				["bg-system-emphasis"] = isHovered or isDragging,
				["bg-surface-0"] = not (isHovered or isDragging),
			},
			Size = if isHorizontal then UDim2.new(0, VISUAL_SIZE, 1, 0) else UDim2.new(1, 0, 0, VISUAL_SIZE),
			backgroundStyle = if isHovered or isDragging then tokens.Color.Extended.Blue.Blue_400 else nil,
		}),

		DragDetector = React.createElement("UIDragDetector", {
			CursorIcon = cursorIcon,
			ActivatedCursorIcon = cursorIcon,
			DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
			[React.Event.DragContinue] = onDragContinue,
			[React.Event.DragStart] = onDragStart,
			[React.Event.DragEnd] = onDragEnd,
		}),
	})
end

return React.memo(Dragger)
