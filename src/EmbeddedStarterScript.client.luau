local Players = game:GetService("Players")
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

local playerGui = localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Flipbook"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local FlipbookCore = (require :: any)(script.Parent.workspace["flipbook-core"].src)

local app = FlipbookCore.createFlipbookExperience(screenGui, {
	initialStoryPath = getInitialStoryPath(),
})

script.Destroying:Connect(app.destroy)
