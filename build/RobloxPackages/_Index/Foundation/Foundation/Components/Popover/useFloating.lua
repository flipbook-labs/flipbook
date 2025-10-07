local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local PopoverSide = require(Foundation.Enums.PopoverSide)
local PopoverAlign = require(Foundation.Enums.PopoverAlign)
local positioning = require(script.Parent.positioning)
local Services = require(Foundation.Utility.Wrappers).Services
local UserInputService = Services.UserInputService
local GuiService = Services.GuiService

local Flags = require(Foundation.Utility.Flags)
local Types = require(Foundation.Components.Types)

type PopoverSide = PopoverSide.PopoverSide
type PopoverAlign = PopoverAlign.PopoverAlign
type PopoverAnchor = Types.PopoverAnchor

export type SideConfig = {
	position: PopoverSide,
	offset: number,
} | PopoverSide

export type AlignConfig = {
	position: PopoverAlign,
	offset: number,
} | PopoverAlign

-- Conditionally connects signals, which useEventConnection does not support
local function useConnectSignals(
	instance: PopoverAnchor? | Instance?,
	signalNames: { string },
	callbackRef: (() -> ()) | { current: () -> () }
)
	local connections = React.useRef({})

	React.useEffect(function()
		if instance ~= nil then
			for _, signalName in signalNames do
				-- This condition is here because of type system quircks. Feel free to simplify with the solver V2 or make a cast, it's horrific.
				local signal = if typeof(instance) == "Instance"
					then instance:GetPropertyChangedSignal(signalName)
					else instance:GetPropertyChangedSignal(signalName)
				connections.current[signalName] = (signal :: Types.MeasurableObjectSignal<any>):Connect(
					if type(callbackRef) == "table"
						then function()
							callbackRef.current()
						end
						else callbackRef
				)
			end
		end

		return function()
			for _, connection in connections.current do
				connection:Disconnect()
			end
		end
	end, { instance :: any, callbackRef })
end

local function useFloating(
	isOpen: boolean,
	anchor: PopoverAnchor?,
	content: GuiObject?,
	overlay: GuiBase2d?,
	sideConfig: SideConfig,
	alignConfig: AlignConfig,
	arrowSize: number?
)
	local position, setPosition = React.useBinding(Vector2.new())
	local isVisible, setIsVisible = React.useBinding(true)
	local contentSize, setContentSize = React.useBinding(UDim2.new())
	local screenSize, setScreenSize = React.useBinding(Vector2.new())
	local arrowPosition, setArrowPosition = React.useBinding(Vector2.new())
	local recalculatePositionRef = React.useRef(function() end)

	local recalculatePosition = React.useCallback(function()
		if not isOpen or not anchor or not content or not overlay then
			setIsVisible(false)
			return
		end

		local anchorPosition = anchor.AbsolutePosition
		local anchorSize = anchor.AbsoluteSize
		-- selene: allow(shadowing)
		local contentSize = content.AbsoluteSize
		-- selene: allow(shadowing)
		local screenSize = overlay.AbsoluteSize
		local screenPosition = overlay.AbsolutePosition
		local anchorRect = Rect.new(anchorPosition, anchorPosition + anchorSize)
		local screenRect = Rect.new(screenPosition, screenPosition + screenSize)

		if Flags.FoundationPopoverOnScreenKeyboard and UserInputService.OnScreenKeyboardVisible then
			screenRect = positioning.adjustForOnScreenKeyboard(
				screenRect,
				UserInputService.OnScreenKeyboardPosition,
				GuiService:GetGuiInset()
			)
		end

		-- If the anchor is not visible on the screen, hide the popover
		if not positioning.isOnScreen(anchorRect, screenRect) then
			setIsVisible(false)
			return
		end

		local side: PopoverSide = if type(sideConfig) == "table" then sideConfig.position else sideConfig
		local sideOffset = if type(sideConfig) == "table" then sideConfig.offset else 0
		local align: PopoverAlign = if type(alignConfig) == "table" then alignConfig.position else alignConfig
		local alignOffset = if type(alignConfig) == "table" then alignConfig.offset else 0
		local arrowOffset = arrowSize or 0

		-- If the content is too large to fit on selected side, switch sides if space allows on the other side
		side = positioning.calculateSide(side, sideOffset, anchorRect, screenRect, arrowOffset, contentSize)

		local calculatedPosition, calculatedArrowPosition = positioning.calculatePositions(
			side,
			sideOffset,
			align,
			alignOffset,
			anchorRect,
			screenRect,
			arrowOffset,
			contentSize
		)

		setContentSize(UDim2.fromOffset(contentSize.X, contentSize.Y))
		setScreenSize(screenSize)
		setArrowPosition(calculatedArrowPosition + calculatedPosition)
		setPosition(calculatedPosition)
		setIsVisible(true)

		-- Force update re-layout for quantum GUI to prevent jello effect
		-- https://roblox.atlassian.net/wiki/spaces/UIC/pages/1588593391/Quantum+Gui
		local _ = content.AbsolutePosition
	end, { isOpen :: unknown, anchor, content, overlay, sideConfig, alignConfig, arrowSize })
	recalculatePositionRef.current = recalculatePosition

	React.useLayoutEffect(function()
		recalculatePosition()
	end, { recalculatePosition })

	useConnectSignals(anchor, { "AbsolutePosition", "AbsoluteSize" }, recalculatePositionRef)
	useConnectSignals(content, { "AbsoluteSize" }, recalculatePositionRef)
	useConnectSignals(overlay, { "AbsoluteSize" }, recalculatePositionRef)
	if Flags.FoundationPopoverOnScreenKeyboard then
		useConnectSignals(
			UserInputService,
			{ "OnScreenKeyboardVisible", "OnScreenKeyboardPosition" },
			recalculatePositionRef
		)
	end

	return position, isVisible, contentSize, arrowPosition, screenSize
end

return useFloating
