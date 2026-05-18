local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsRunning() then
	return
end

local localPlayer = Players.LocalPlayer
if localPlayer == nil then
	return
end

local function getInitialStoryPath(): string?
	local launchData = localPlayer:GetJoinData().LaunchData
	if launchData == nil or launchData == "" then
		return nil
	end

	return launchData:match("[?&]story=([^&]+)") or launchData:match("[?&]storyPath=([^&]+)")
end

local function getStoryRoot(): Instance?
	local launchData = localPlayer:GetJoinData().LaunchData
	if launchData == nil or launchData == "" then
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

local FlipbookCore = (require :: any)(script.Parent.workspace["flipbook-core"].src)

local app = FlipbookCore.createFlipbookExperience(screenGui, {
	initialStoryPath = getInitialStoryPath(),
	storyRoot = getStoryRoot(),
})

script.Destroying:Connect(app.destroy)
