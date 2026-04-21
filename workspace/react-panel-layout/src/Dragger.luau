local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local useRef = React.useRef
local useState = React.useState
local useCallback = React.useCallback
local useTokens = Foundation.Hooks.useTokens

local HITBOX_SIZE = 8
local VISUAL_SIZE = 2
local COLOR = Color3.fromRGB(60, 60, 60)
local HOVER_COLOR = Color3.fromRGB(124, 0, 212)
local HOVER_ICON_X = "rbxasset://textures/StudioUIEditor/icon_resize2.png"
local HOVER_ICON_Y = "rbxasset://textures/StudioUIEditor/icon_resize4.png"

export type PanelSeparatorProps = {
	panelA: string,
	panelB: string,
	LayoutOrder: number,
}

local function PanelSeparator(props: PanelSeparatorProps)
	local isHovered, setIsHovered = useState(false)
	local ref = useRef(nil :: UIDragDetector?)
	local isDragging, setIsDragging = useState(false)
	local lastDragPosition = useRef(nil :: Vector2?)
	local tokens = useTokens()

	local isHorizontal = false

	local activeColor = if isHovered then HOVER_COLOR else COLOR

	local onHover = React.useCallback(function()
		setIsHovered(true)
	end, {})

	local onUnhover = React.useCallback(function()
		setIsHovered(false)
	end, {})

	local onStateChanged = useCallback(
		function(newState)
			setIsHovered(newState == Foundation.Enums.ControlState.Hover)
		end :: Foundation.StateChangedCallback,
		{}
	)

	local onDragContinue = useCallback(function(rbx: UIDragDetector, inputPosition: Vector2)
		-- TODO
	end, {})

	local onDragStart = useCallback(function(_rbx: UIDragDetector, _inputPosition: Vector2)
		setIsDragging(true)
	end, {})

	local onDragEnd = useCallback(function(_rbx: UIDragDetector, _inputPosition: Vector2)
		setIsDragging(false)
	end, {})

	return React.createElement(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		Size = if isHorizontal then UDim2.new(0, HITBOX_SIZE, 1, 0) else UDim2.new(1, 0, 0, HITBOX_SIZE),
		onStateChanged = onStateChanged,
	}, {
		Visual = React.createElement(Foundation.View, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = if isHorizontal then UDim2.new(0, VISUAL_SIZE, 1, 0) else UDim2.new(1, 0, 0, VISUAL_SIZE),
			backgroundStyle = if isHovered or isDragging then tokens.Color.Extended.Blue.Blue_400 else nil,
		}),

		DragDetector = React.createElement("UIDragDetector", {
			CursorIcon = if isHorizontal then HOVER_ICON_X else HOVER_ICON_Y,
			ActivatedCursorIcon = if isHorizontal then HOVER_ICON_X else HOVER_ICON_Y,
			DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
			[React.Event.DragContinue] = onDragContinue,
			[React.Event.DragStart] = onDragStart,
			[React.Event.DragEnd] = onDragEnd,
			Enabled = true,
			ref = ref,
		}),
	})
end

return PanelSeparator
