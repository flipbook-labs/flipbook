--!nocheck
--[[
	This is a temporary layer to abstract the constants and configuration for different platform.
		It will be replaced by design tokens in the near future.
]]

-- moving this file to LuaApps, please replicate any changes in the LuaApps file as well
local DetailsPage = script.Parent
local App = DetailsPage.Parent.Parent

local Constants = require(App.Style.Constants)
type DeviceType = Constants.DeviceType
local DeviceType = Constants.DeviceType

local UIBlox = App.Parent
local UIBloxConfig = require(UIBlox.UIBloxConfig)

export type DetailsPageConfig = {
	startingOffsetPosition: number,
	thumbnailHeight: number,
	dualPanelBreakpoint: number,
	headerBarBackgroundHeight: number,
	sideMargin: number,
}

-- These will be configured through design tokens in the future
local DetailsPageConfigs = {
	[DeviceType.Desktop] = {
		startingOffsetPosition = 500,
		thumbnailHeight = 200,
		dualPanelBreakpoint = 1280,
		headerBarBackgroundHeight = 80,
		sideMargin = 48,
	},
	[DeviceType.Tablet] = {
		startingOffsetPosition = 200,
		thumbnailHeight = 150,
		dualPanelBreakpoint = math.huge, -- This would effectively mean tablet will be locked to single panel
		headerBarBackgroundHeight = 80,
		sideMargin = 48,
	},
	[DeviceType.Phone] = {
		startingOffsetPosition = 250,
		thumbnailHeight = 100,
		dualPanelBreakpoint = math.huge, -- This would effectively mean phone will be locked to single panel
		headerBarBackgroundHeight = 24,
		sideMargin = 24,
	},
	[DeviceType.Console] = {
		startingOffsetPosition = 500,
		thumbnailHeight = 200,
		dualPanelBreakpoint = 1280,
		headerBarBackgroundHeight = 80,
		sideMargin = 48,
	},
	[DeviceType.VR] = {
		startingOffsetPosition = 500,
		thumbnailHeight = 200,
		dualPanelBreakpoint = 1280,
		headerBarBackgroundHeight = 80,
		sideMargin = 48,
	},
}

local function getPlatformConfig(deviceType: DeviceType): DetailsPageConfig
	local config = DetailsPageConfigs[deviceType]
	if config == nil then
		return DetailsPageConfigs[DeviceType.Desktop]
	else
		return config
	end
end

return (if UIBloxConfig.moveDetailsPageToLuaApps then nil else getPlatformConfig) :: typeof(getPlatformConfig)
