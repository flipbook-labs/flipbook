local RunService = game:GetService("RunService")

local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local PluginStore = require("@root/Plugin/PluginStore")
local types = require("@root/Panels/types")
local useColors = require("@root/Common/useColors")

local useSignalState = SignalsReact.useSignalState

local defaultProps = {
	size = 8, -- px
	hoverIconX = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	hoverIconY = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
}

local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

export type Props = {
	handle: types.DragHandle,
	onDrag: (delta: Vector2) -> (),
	onDragEnd: (() -> ())?,
}

type InternalProps = Props & typeof(defaultProps)

local function DragHandle(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)
	local colors = useColors()

	local pluginStore = useSignalState(PluginStore.get)
	local plugin = useSignalState(pluginStore.getPlugin)

	local isDragging, setIsDragging = useState(false)
	local isHovered, setIsHovered = useState(false)
	local mouseInput: InputObject?, setMouseInput = useState(nil :: InputObject?)

	local getHandleProperties = useCallback(function()
		local hitboxSize: UDim2
		local highlightSize: UDim2
		local position: UDim2
		local anchorPoint: Vector2

		if props.handle == "Right" or props.handle == "Left" then
			hitboxSize = UDim2.new(0, props.size, 1, 0)
			highlightSize = UDim2.new(0, props.size / 4, 1, 0)

			if props.handle == "Right" then
				position = UDim2.fromScale(1, 0)
				anchorPoint = Vector2.new(0.5, 0)
			else
				position = UDim2.fromScale(0, 0)
				anchorPoint = Vector2.new(0, 0)
			end
		elseif props.handle == "Top" or props.handle == "Bottom" then
			hitboxSize = UDim2.new(1, 0, 0, props.size)
			highlightSize = UDim2.new(1, 0, 0, props.size / 4)

			if props.handle == "Bottom" then
				position = UDim2.fromScale(0, 1)
				anchorPoint = Vector2.new(0, 0.5)
			else
				position = UDim2.fromScale(0, 0)
				anchorPoint = Vector2.new(0, 0)
			end
		end

		return hitboxSize, highlightSize, position, anchorPoint
	end, { props.handle, props.size } :: { unknown })

	local onInputBegan = useCallback(function(_rbx, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setIsDragging(true)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setIsHovered(true)
			setMouseInput(input)
		end
	end, { isDragging })

	local onInputEnded = useCallback(function(_rbx, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setIsDragging(false)
			setMouseInput(nil)

			if props.onDragEnd then
				props.onDragEnd()
			end
		end
	end, { props.onDragEnd })

	local onMouseEnter = useCallback(function()
		setIsHovered(true)
	end, {})

	local onMouseLeave = useCallback(function()
		setIsHovered(false)
	end, {})

	local hitboxSize, highlightSize, position, anchorPoint = getHandleProperties()

	useEffect(function(): any
		if mouseInput and isDragging then
			local lastPosition = mouseInput.Position
			local conn = RunService.Heartbeat:Connect(function()
				local delta = mouseInput.Position - lastPosition

				if props.onDrag and delta ~= Vector3.zero then
					props.onDrag(Vector2.new(delta.X, delta.Y))
				end

				lastPosition = mouseInput.Position
			end)

			return function()
				conn:Disconnect()
			end
		else
			return nil
		end
	end, { mouseInput, isDragging } :: { unknown })

	useEffect(function()
		if plugin then
			local mouse = plugin:GetMouse()

			if isHovered or isDragging then
				if props.handle == "Left" or props.handle == "Right" then
					mouse.Icon = props.hoverIconX
				elseif props.handle == "Top" or props.handle == "Bottom" then
					mouse.Icon = props.hoverIconY
				end
			else
				mouse.Icon = ""
			end
		end
	end, { plugin, isDragging, isHovered } :: { unknown })

	return React.createElement("ImageButton", {
		Size = hitboxSize,
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
		[React.Event.InputBegan] = onInputBegan,
		[React.Event.InputEnded] = onInputEnded,
		[React.Event.MouseEnter] = onMouseEnter :: any,
		[React.Event.MouseLeave] = onMouseLeave :: any,
	}, {
		Highlght = React.createElement("Frame", {
			Size = highlightSize,
			BorderSizePixel = 0,
			BackgroundTransparency = if isHovered or isDragging then colors.accent.Transparency else 1,
			BackgroundColor3 = colors.accent.Color3,
		}),
	})
end

return DragHandle
