local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

if not RunService:IsRunning() then
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

local app = FlipbookCore.createFlipbookExperience(screenGui, {
	initialStoryPath = getInitialStoryPath(),
	storyRoot = getStoryRoot(),
})

script.Destroying:Connect(app.destroy)
