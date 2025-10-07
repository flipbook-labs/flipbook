local RunService = game:GetService("RunService")

local React = require(script.Parent.Parent.Packages.React)
local Sift = require(script.Parent.Parent.Packages.Sift)
local SignalsReact = require(script.Parent.Parent.RobloxPackages.SignalsReact)

local PluginStore = require(script.Parent.Parent.Plugin.PluginStore)
local types = require(script.Parent.types)
local useTheme = require(script.Parent.Parent.Common.useTheme)

local useSignalState = SignalsReact.useSignalState

local defaultProps = {
	size = 8, -- px
	hoverIconX = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	hoverIconY = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
}

export type Props = {
	handle: types.DragHandle,
	onDrag: (delta: Vector2) -> (),
	onDragEnd: (() -> ())?,
}

type InternalProps = Props & typeof(defaultProps)

local function DragHandle(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)
	local theme = useTheme()

	local pluginStore = useSignalState(PluginStore.get)
	local plugin = useSignalState(pluginStore.getPlugin)

	local isDragging, setIsDragging = React.useState(false)
	local isHovered, setIsHovered = React.useState(false)
	local mouseInput: InputObject?, setMouseInput = React.useState(nil :: InputObject?)

	local getHandleProperties = React.useCallback(function()
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

	local onInputBegan = React.useCallback(function(_rbx, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setIsDragging(true)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setIsHovered(true)
			setMouseInput(input)
		end
	end, { isDragging })

	local onInputEnded = React.useCallback(function(_rbx, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setIsDragging(false)
			setMouseInput(nil)

			if props.onDragEnd then
				props.onDragEnd()
			end
		end
	end, { props.onDragEnd })

	local onMouseEnter = React.useCallback(function()
		setIsHovered(true)
	end, {})

	local onMouseLeave = React.useCallback(function()
		setIsHovered(false)
	end, {})

	local hitboxSize, highlightSize, position, anchorPoint = getHandleProperties()

	React.useEffect(function(): any
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

	React.useEffect(function()
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
			BackgroundTransparency = if isHovered or isDragging then 0 else 1,
			BackgroundColor3 = theme.selection,
		}),
	})
end

return DragHandle
