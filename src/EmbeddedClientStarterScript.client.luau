--[[
	There are two ways to embed Flipbook into an experience:

	1. By using the "Embed into Experience" dialog, which allows you to select a
	   destination in the Explorer where Flipbook will clone itself to.

	2. By using flipbook-cli to deploy the latest release of Flipbook to an
	   experience
]]

-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local prefix = `[{script.Name}]`

local localPlayer = Players.LocalPlayer
if localPlayer == nil then
	return
end

local startClock = os.clock()
print(`{prefix} starting...`)

type LaunchData = {
	initialStoryPath: string?,
	storyRootPath: string?,
}

local function parseLaunchData(launchDataStr: string): LaunchData
	local success, launchData = pcall(function()
		return HttpService:JSONDecode(launchDataStr)
	end)
	if not success then
		warn(`{prefix} Failed to parse launch data: {launchDataStr}`)
		return {}
	end
	return launchData
end

-- Resolves the story root path (e.g. "Folder/SubFolder") to a live Instance
-- under ReplicatedStorage. Returns nil when no story root was requested or it
-- couldn't be found in time.
local function resolveStoryRoot(storyRootPath: string): Instance?
	local current: Instance = ReplicatedStorage
	for segment in storyRootPath:gmatch("[^/]+") do
		print(`{prefix} resolving story root segment "{segment}" under {current:GetFullName()}...`)
		local child = current:WaitForChild(segment, 10)
		if child == nil then
			warn(`{prefix} Timed out waiting for story root segment "{segment}"`)
			return nil
		end
		current = child
	end
	print(`{prefix} resolved story root to {current:GetFullName()}`)
	return current
end

local joinData = localPlayer:GetJoinData()

print("LaunchData", joinData.LaunchData)
local launchData = parseLaunchData(joinData.LaunchData)

print(`{prefix} setting up Flipbook UI...`)
local playerGui = localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Flipbook"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local FlipbookCore = require("@workspace/flipbook-core/src")

local storyRoot = if launchData.storyRootPath then resolveStoryRoot(launchData.storyRootPath) else nil

FlipbookCore.createEmbeddedFlipbookApp(screenGui, {
	initialStoryPath = launchData.initialStoryPath,
	storyRoot = storyRoot,
})

print(`{prefix} successfully initialized in {os.clock() - startClock}s`)
