--!nocheck
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local VRRoot = script.Parent
local Packages = VRRoot.Parent.Parent.Parent
local React = require(Packages.React)
local Roact = require(Packages.Roact)

local ReactUtils = require(Packages.ReactUtils)
local EventConnection = ReactUtils.EventConnection

local LuauPolyfill = require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local Constants = require(VRRoot.Constants)

local UIBloxConfig = require(Packages.UIBlox.UIBloxConfig)

type VRControllerModel = {
	update: () -> (),
	setEnabled: (enabled: boolean) -> (),
	new: (modelEnum: Enum.UserCFrame) -> VRControllerModel,
}

type VRService = {
	VREnabled: boolean,
	GetPropertyChangedSignal: (self: VRService, property: string) -> (),
}
type LaserPointer = {
	setMode: (mode: number) -> (),
	setEnableAmbidexterousPointer: (enabled: boolean) -> (),
	disableComponent: () -> (),
	new: () -> LaserPointer,
}

export type PointerOverlayProps = {
	LaserPointer: LaserPointer,
	VRControllerModel: VRControllerModel,
	VRService: VRService,
	UpdateEvent: RBXScriptSignal,
}

local defaultProps: PointerOverlayProps = {
	VRService = game:GetService("VRService"),
	UpdateEvent = RunService.Heartbeat,
}

local function setLaserPointerModeBasedOnUserCFrame(LaserPointer, VRService)
	if
		VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand)
		and VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
	then
		LaserPointer.current:setMode(LaserPointer.current.Mode["DualPointer"])
	elseif
		not VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand)
		and not VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
	then
		LaserPointer.current:setMode(LaserPointer.current.Mode["Disabled"])
	else
		LaserPointer.current:setMode(LaserPointer.current.Mode["Pointer"])
	end
end

local function PointerOverlay(providedProps: PointerOverlayProps)
	local props = Object.assign({}, defaultProps, providedProps)

	-- props types
	local LaserPointerComponent = props.LaserPointer
	local VRControllerModel = props.VRControllerModel
	local VRService = props.VRService

	-- Set up refs and state
	local LaserPointer: Constants.Ref<Part?> = React.useRef(nil)
	local LeftControllerModel: Constants.Ref<Part?> = React.useRef(nil)
	local RightControllerModel: Constants.Ref<Part?> = React.useRef(nil)

	local vrSessionStateAvailable, vrSessionStateSignal = pcall(function()
		return VRService:GetPropertyChangedSignal("VRSessionState")
	end)

	local VREnabledCallback = React.useCallback(function()
		if not LaserPointer.current then
			LaserPointer.current = LaserPointerComponent.new()
			if UIBloxConfig.enableBetterLaserPointerMode then
				setLaserPointerModeBasedOnUserCFrame(LaserPointer, VRService)
			else
				LaserPointer.current:setMode(LaserPointer.current.Mode["DualPointer"])
			end
			LaserPointer.current:setEnableAmbidexterousPointer(true)
			LeftControllerModel.current = VRControllerModel.new(Enum.UserCFrame.LeftHand)
			RightControllerModel.current = VRControllerModel.new(Enum.UserCFrame.RightHand)
		end

		LeftControllerModel.current:setEnabled(VRService.VREnabled)
		RightControllerModel.current:setEnabled(VRService.VREnabled)
		if VRService.VREnabled then
			ContextActionService:BindActivate(
				Enum.UserInputType.Gamepad1,
				Enum.KeyCode.ButtonA,
				Enum.KeyCode.ButtonX,
				Enum.KeyCode.ButtonR2,
				Enum.KeyCode.ButtonL2
			)
		end
	end, { LeftControllerModel, RightControllerModel, LaserPointer, LaserPointerComponent, VRControllerModel })

	local VRDisabledCallback
	VRDisabledCallback = React.useCallback(function()
		if LeftControllerModel.current then
			LeftControllerModel.current:setEnabled(false)
		end
		if RightControllerModel.current then
			RightControllerModel.current:setEnabled(false)
		end
		if LaserPointer.current then
			if UIBloxConfig.fixLaserPointerDisable then
				LaserPointer.current:disableComponent()
			else
				LaserPointer.current:setMode(LaserPointer.current.Mode["Disabled"])
			end
		end
		ContextActionService:UnbindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA)
		ContextActionService:UnbindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
	end, { LeftControllerModel, RightControllerModel, LaserPointer, LaserPointerComponent, VRControllerModel })

	local VRSessionStateCallback = React.useCallback(function()
		local overlayEnabled = not (
			VRService.VRSessionState == Enum.VRSessionState.Idle
			or VRService.VRSessionState == Enum.VRSessionState.Visible
		)
		if LaserPointer.current then
			if overlayEnabled then
				if UIBloxConfig.enableBetterLaserPointerMode then
					setLaserPointerModeBasedOnUserCFrame(LaserPointer, VRService)
				else
					LaserPointer.current:setMode(LaserPointer.current.Mode["DualPointer"])
				end
			else
				LaserPointer.current:setMode(LaserPointer.current.Mode["Disabled"])
			end
		end
		if LeftControllerModel.current then
			LeftControllerModel.current:setEnabled(overlayEnabled)
		end
		if RightControllerModel.current then
			RightControllerModel.current:setEnabled(overlayEnabled)
		end
	end, { LeftControllerModel, RightControllerModel, LaserPointer, LaserPointerComponent, VRControllerModel })

	local VRUserCFrameEnabledCallback = React.useCallback(function()
		setLaserPointerModeBasedOnUserCFrame(LaserPointer, VRService)
	end, { LaserPointer })

	-- Runs on first render, in case we start with VREnabled = true
	React.useEffect(function()
		if VRService.VREnabled then
			VREnabledCallback()
		end
		return VRDisabledCallback
	end, {})

	return React.createElement(Roact.Portal, {
		target = workspace,
	}, {
		UserCFrameChangedConnection = React.createElement(EventConnection, {
			event = props.UpdateEvent,
			callback = function()
				if LaserPointer.current then
					LaserPointer.current:update()
				end
				if LeftControllerModel.current then
					LeftControllerModel.current:update()
				end
				if RightControllerModel.current then
					RightControllerModel.current:update()
				end
			end,
		}),
		VREnabledConnection = React.createElement(EventConnection, {
			event = VRService:GetPropertyChangedSignal("VREnabled"),
			callback = VREnabledCallback,
		}),
		VRUserCFrameEnabledConnection = if UIBloxConfig.enableBetterLaserPointerMode
			then React.createElement(EventConnection, {
				event = VRService.UserCFrameEnabled,
				callback = VRUserCFrameEnabledCallback,
			})
			else nil,
		VRSessionStateConnection = if vrSessionStateAvailable
			then React.createElement(EventConnection, {
				event = vrSessionStateSignal,
				callback = VRSessionStateCallback,
			})
			else nil,
	})
end

return PointerOverlay
