local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local PanelGroupContext = require("@root/PanelGroupContext")
local computeDraggedSizes = require("@root/computeDraggedSizes")

local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

export type PanelSeparatorProps = {
	LayoutOrder: number,
	beforeId: string,
	afterId: string,
	hitboxSize: number?,
	visualSize: number?,
	color: Color3?,
	hoverColor: Color3?,
	hoverIconX: string?,
	hoverIconY: string?,
}

local defaultProps = {
	hitboxSize = 8,
	visualSize = 1,
	color = Color3.fromRGB(60, 60, 60),
	hoverColor = Color3.fromRGB(0, 120, 212),
	hoverIconX = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	hoverIconY = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
}

type Props = typeof(defaultProps) & PanelSeparatorProps

local function PanelSeparator(panelSeparatorProps: PanelSeparatorProps)
	local props: Props = Sift.Dictionary.join(defaultProps, panelSeparatorProps)

	local context = PanelGroupContext.use()
	local isHovered, setIsHovered = useState(false)

	-- Keep latest context in a ref so drag callbacks never go stale
	local contextRef = useRef(context)
	useEffect(function()
		contextRef.current = context
	end)

	local lastPosRef = useRef(nil :: Vector2?)

	local function applyDelta(deltaScalar: number)
		if deltaScalar == 0 then
			return
		end

		local ctx = contextRef.current
		local isHorizontal = ctx.orientation == "horizontal"
		local sizes = ctx.sizes
		local constraints = ctx.panelConstraints
		local availablePx = if isHorizontal
			then ctx.groupAbsoluteSize.X - ctx.separatorsTotalSize
			else ctx.groupAbsoluteSize.Y - ctx.separatorsTotalSize

		local beforeOld = sizes[props.beforeId] or 0
		local afterOld = sizes[props.afterId] or 0

		local newBeforeRatio, newAfterRatio = computeDraggedSizes(
			availablePx,
			deltaScalar,
			beforeOld,
			afterOld,
			constraints[props.beforeId],
			constraints[props.afterId]
		)

		local newSizes = table.clone(sizes)
		newSizes[props.beforeId] = newBeforeRatio
		newSizes[props.afterId] = newAfterRatio
		ctx.updateSizes(newSizes)
	end

	-- Register this separator's pixel footprint with the group
	useEffect(function()
		context.registerSeparator(props.hitboxSize)
		return function()
			context.unregisterSeparator(props.hitboxSize)
		end
	end, {}) -- intentionally empty: mount/unmount only

	local isHorizontal = context.orientation == "horizontal"

	local hitboxFrameSize = if isHorizontal
		then UDim2.new(0, props.hitboxSize, 1, 0)
		else UDim2.new(1, 0, 0, props.hitboxSize)
	local visualFrameSize = if isHorizontal
		then UDim2.new(0, props.visualSize, 1, 0)
		else UDim2.new(1, 0, 0, props.visualSize)

	local activeColor = if isHovered then props.hoverColor else props.color

	local onDragStart = React.useCallback(function(_rbx: UIDragDetector, inputPosition: Vector2)
		lastPosRef.current = inputPosition
	end, {})

	local onDragContinue = React.useCallback(function(_rbx: UIDragDetector, inputPosition: Vector2)
		local lastPos = lastPosRef.current
		if not lastPos then
			return
		end
		lastPosRef.current = inputPosition
		local delta = inputPosition - lastPos
		local ctx = contextRef.current
		applyDelta(if ctx.orientation == "horizontal" then delta.X else delta.Y)
	end, {})

	local onDragEnd = React.useCallback(function(_rbx: UIDragDetector, _inputPosition: Vector2)
		lastPosRef.current = nil
	end, {})

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		Size = hitboxFrameSize,
		BackgroundTransparency = 1,
		Active = true,
		[React.Event.MouseEnter] = function()
			setIsHovered(true)
		end :: any,
		[React.Event.MouseLeave] = function()
			setIsHovered(false)
		end :: any,
	}, {
		Visual = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = visualFrameSize,
			BackgroundColor3 = activeColor,
			BorderSizePixel = 0,
		}),

		DragDetector = React.createElement("UIDragDetector", {
			ActivatedCursorIcon = if isHorizontal then props.hoverIconX else props.hoverIconY,
			CursorIcon = if isHorizontal then props.hoverIconX else props.hoverIconY,
			DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
			[React.Event.DragContinue] = onDragContinue,
			[React.Event.DragStart] = onDragStart,
			[React.Event.DragEnd] = onDragEnd,
			Enabled = true,
			ref = function(rbx: UIDragDetector?)
				if rbx then
					-- Prevent UIDragDetector from repositioning the frame;
					-- panel sizes drive layout, not separator position.
					rbx:SetDragStyleFunction(function()
						return UDim2.fromOffset(0, 0), 0
					end)
				end
			end,
		}),
	})
end

return PanelSeparator
