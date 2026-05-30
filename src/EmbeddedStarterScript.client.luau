--[[
	There are two ways to embed Flipbook into an experience:

	1. By using the "Embed into Experience" dialog, which allows you to select a
	   destination in the Explorer where Flipbook will clone itself to.

	2. By using flipbook-cli to deploy the latest release of Flipbook to an
	   experience
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Fun fact: GetService doesn't throw when the client attempts to access
-- PluginDebugService. Just returns nil. But the type doesn't match that. So to
-- explicitly show the intent we're using FindService and an annotation.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")

-- This script—even when included with the plugin—will run when playing the
-- experience in Studio, so we need to make sure to early exit in that case
if PluginDebugService and script:IsDescendantOf(PluginDebugService) then
	return
end

local localPlayer = Players.LocalPlayer
if localPlayer == nil then
	return
end

local function getLaunchData(): string?
	local launchData = localPlayer:GetJoinData().LaunchData
	if launchData == nil or launchData == "" then
		return nil
	end
	return launchData
end

local function getTeleportPlaceId(): number?
	local launchData = getLaunchData()
	if launchData == nil then
		return nil
	end

	local placeIdStr = launchData:match("[?&]placeId=([^&]+)")
	if placeIdStr == nil then
		return nil
	end

	return tonumber(placeIdStr)
end

local function tryTeleportToLaunchPlace(): boolean
	local placeId = getTeleportPlaceId()
	if placeId == nil or placeId == game.PlaceId then
		return false
	end

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(placeId, { localPlayer })
	end)

	if not ok then
		warn(`Flipbook hub failed to teleport to place {placeId}: {err}`)
	end

	return true
end

if tryTeleportToLaunchPlace() then
	return
end

local function getInitialStoryPath(): string?
	local launchData = getLaunchData()
	if launchData == nil then
		return nil
	end

	return launchData:match("[?&]story=([^&]+)") or launchData:match("[?&]storyPath=([^&]+)")
end

local function getStoryRoot(): Instance?
	local launchData = getLaunchData()
	if launchData == nil then
		return nil
	end

	local path = launchData:match("[?&]storyRoot=([^&]+)")
	if path == nil then
		return nil
	end

	local current: Instance = ReplicatedStorage
	for segment in path:gmatch("[^/]+") do
		local child = current:WaitForChild(segment, 10)
		if child == nil then
			return nil
		end
		current = child
	end
	return current
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Flipbook"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local FlipbookCore = require("@workspace/flipbook-core/src")

FlipbookCore.createEmbeddedFlipbookApp(screenGui, {
	initialStoryPath = getInitialStoryPath(),
	storyRoot = getStoryRoot(),
})
