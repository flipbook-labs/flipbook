local React = require("@pkg/React")

local PanelGroupContext = require("@root/PanelGroupContext")
local computeDraggedSizes = require("@root/computeDraggedSizes")
local types = require("@root/types")

local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

local DEFAULT_HITBOX_SIZE = 8 -- px, interactive area
local DEFAULT_VISUAL_SIZE = 1 -- px, visible line
local DEFAULT_COLOR = Color3.fromRGB(60, 60, 60)
local DEFAULT_HOVER_COLOR = Color3.fromRGB(0, 120, 212)

export type Props = types.PanelSeparatorProps

local function PanelSeparator(props: Props)
	local hitboxSize = props.hitboxSize or DEFAULT_HITBOX_SIZE
	local visualSize = props.visualSize or DEFAULT_VISUAL_SIZE
	local color = props.color or DEFAULT_COLOR
	local hoverColor = props.hoverColor or DEFAULT_HOVER_COLOR

	local context = PanelGroupContext.use()
	local isHovered, setIsHovered = useState(false)

	-- Keep latest context in a ref so drag callbacks never go stale
	local contextRef = useRef(context)
	useEffect(function()
		contextRef.current = context
	end)

	local dragDetectorRef = useRef(nil :: UIDragDetector?)

	-- Register this separator's pixel footprint with the group
	useEffect(function()
		context.registerSeparator(hitboxSize)
		return function()
			context.unregisterSeparator(hitboxSize)
		end
	end, {}) -- intentionally empty: mount/unmount only

	-- Wire up UIDragDetector events once after mount (ref is set by then)
	useEffect(function(): (() -> ())?
		local dd = dragDetectorRef.current
		if not dd then
			return nil
		end

		-- Prevent UIDragDetector from repositioning the frame —
		-- the panel sizes drive layout, not the separator's position.
		dd:SetDragStyleFunction(function()
			return nil
		end)

		local lastPos: Vector2? = nil

		local startConn = dd.DragStart:Connect(function(inputPosition: Vector2)
			lastPos = inputPosition
		end)

		local continueConn = dd.DragContinue:Connect(function(inputPosition: Vector2)
			if not lastPos then
				return
			end

			local delta = inputPosition - lastPos
			lastPos = inputPosition

			local ctx = contextRef.current
			local isHorizontal = ctx.orientation == "horizontal"
			local deltaScalar = if isHorizontal then delta.X else delta.Y

			if deltaScalar == 0 then
				return
			end

			local sizes = ctx.sizes
			local constraints = ctx.panelConstraints
			local availablePx = if isHorizontal
				then ctx.groupAbsoluteSize.X - ctx.separatorsTotalSize
				else ctx.groupAbsoluteSize.Y - ctx.separatorsTotalSize

			local newBeforeRatio, newAfterRatio = computeDraggedSizes(
				availablePx,
				deltaScalar,
				sizes[props.beforeId] or 0,
				sizes[props.afterId] or 0,
				constraints[props.beforeId],
				constraints[props.afterId]
			)

			local newSizes = table.clone(sizes)
			newSizes[props.beforeId] = newBeforeRatio
			newSizes[props.afterId] = newAfterRatio
			ctx.updateSizes(newSizes)
		end)

		local endConn = dd.DragEnd:Connect(function()
			lastPos = nil
		end)

		return function()
			startConn:Disconnect()
			continueConn:Disconnect()
			endConn:Disconnect()
		end
	end, {}) -- intentionally empty: mount/unmount only; context accessed via ref

	local isHorizontal = context.orientation == "horizontal"

	local hitboxFrameSize = if isHorizontal then UDim2.new(0, hitboxSize, 1, 0) else UDim2.new(1, 0, 0, hitboxSize)

	local visualFrameSize = if isHorizontal then UDim2.new(0, visualSize, 1, 0) else UDim2.new(1, 0, 0, visualSize)

	local activeColor = if isHovered then hoverColor else color

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		Size = hitboxFrameSize,
		BackgroundTransparency = 1,
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
			DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
			ref = dragDetectorRef,
		}),
	})
end

return PanelSeparator
