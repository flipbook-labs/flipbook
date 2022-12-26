local flipbook = script:FindFirstAncestor("flipbook")

local RunService = game:GetService("RunService")

local Sift = require(flipbook.Packages.Sift)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local PluginContext = require(flipbook.Plugin.PluginContext)
local types = require(script.Parent.Parent.types)

local defaultProps = {
	size = 8, -- px
	hoverIconX = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	hoverIconY = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
}

export type Props = typeof(defaultProps) & {
	handle: types.DragHandle,
	onDrag: (delta: Vector2) -> (),
	onDragEnd: (() -> ())?,
}

local function DragHandle(props: Props, hooks: any)
	props = Sift.Dictionary.merge(defaultProps, props)

	local plugin = hooks.useContext(PluginContext.Context)
	local isDragging, setIsDragging = hooks.useState(false)
	local isHovered, setIsHovered = hooks.useState(false)
	local mouseInput: InputObject, setMouseInput = hooks.useState(nil)

	local getHandleProperties = hooks.useCallback(function()
		local size: UDim2
		local position: UDim2
		local anchorPoint: Vector2

		if props.handle == "Right" or props.handle == "Left" then
			size = UDim2.new(0, props.size, 1, 0)

			if props.handle == "Right" then
				position = UDim2.fromScale(1, 0)
				anchorPoint = Vector2.new(0.5, 0)
			else
				position = UDim2.fromScale(0, 0)
				anchorPoint = Vector2.new(0, 0)
			end
		elseif props.handle == "Top" or props.handle == "Bottom" then
			size = UDim2.new(1, 0, 0, props.size)

			if props.handle == "Bottom" then
				position = UDim2.fromScale(0, 1)
				anchorPoint = Vector2.new(0, 0.5)
			else
				position = UDim2.fromScale(0, 0)
				anchorPoint = Vector2.new(0, 0)
			end
		end

		return size, position, anchorPoint
	end, { props.handle, props.size })

	local onInputBegan = hooks.useCallback(function(_rbx, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setIsDragging(true)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setIsHovered(true)
			setMouseInput(input)
		end
	end, { isDragging })

	local onInputEnded = hooks.useCallback(function(_rbx, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setIsDragging(false)
			setMouseInput(nil)

			if props.onDragEnd then
				props.onDragEnd()
			end
		end
	end, { props.onDragEnd })

	local onMouseEnter = hooks.useCallback(function()
		setIsHovered(true)
	end, {})

	local onMouseLeave = hooks.useCallback(function()
		setIsHovered(false)
	end, {})

	local size, position, anchorPoint = getHandleProperties()

	hooks.useEffect(function()
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
	end, { mouseInput, isDragging })

	hooks.useEffect(function()
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
	end, { plugin, isDragging, isHovered })

	return Roact.createElement("ImageButton", {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
		[Roact.Event.InputBegan] = onInputBegan,
		[Roact.Event.InputEnded] = onInputEnded,
		[Roact.Event.MouseEnter] = onMouseEnter,
		[Roact.Event.MouseLeave] = onMouseLeave,
	})
end

return hook(DragHandle)
