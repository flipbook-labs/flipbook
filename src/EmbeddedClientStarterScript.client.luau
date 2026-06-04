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

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local localPlayer = Players.LocalPlayer
if localPlayer == nil then
	return
end

local startClock = os.clock()
print("embedded Flipbook started")

type LaunchData = {
	placeId: number?,
	initialStoryPath: string?,
	storyRootPath: string?,
}

local function parseLaunchData(launchDataStr: string): LaunchData
	local data: { [string]: string } = {}
	for key, value in launchDataStr:gmatch("[?&]([^=&]+)=([^&]+)") do
		if key and value then
			data[key] = value
		end
	end

	return {
		placeId = tonumber(data.placeId),
		initialStoryPath = data.story or data.storyPath,
		storyRootPath = data.storyRoot,
	}
end

local function tryTeleportToLaunchPlace(launchData: LaunchData): boolean
	if launchData.placeId == nil then
		print("no teleport place requested, staying in this place")
		return false
	end

	if launchData.placeId == game.PlaceId then
		print(`already in requested place {launchData.placeId}, skipping teleport`)
		return false
	end

	print(`teleporting to isolated preview at place {launchData.placeId}...`)

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(launchData.placeId, { localPlayer })
	end)

	if not ok then
		warn(`Flipbook hub failed to teleport to place {launchData.placeId}: {err}`)
	end

	return true
end

-- Resolves the story root path (e.g. "Folder/SubFolder") to a live Instance
-- under ReplicatedStorage. Returns nil when no story root was requested or it
-- couldn't be found in time.
local function resolveStoryRoot(launchData: LaunchData): Instance?
	local path = launchData.storyRootPath
	if path == nil then
		return nil
	end

	local current: Instance = ReplicatedStorage
	for segment in path:gmatch("[^/]+") do
		print(`resolving story root segment "{segment}" under {current:GetFullName()}...`)
		local child = current:WaitForChild(segment, 10)
		if child == nil then
			warn(`Timed out waiting for story root segment "{segment}"`)
			return nil
		end
		current = child
	end
	print(`resolved story root to {current:GetFullName()}`)
	return current
end

local joinData = localPlayer:GetJoinData()
local launchData = parseLaunchData(joinData.LaunchData or "")

print(
	`Parsed launch data: placeId={launchData.placeId or "<none>"}, `
		.. `initialStoryPath={launchData.initialStoryPath or "<none>"}, `
		.. `storyRoot={launchData.storyRootPath or "<none>"}`
)

if tryTeleportToLaunchPlace(launchData) then
	return
end

print("setting up Flipbook UI...")
local playerGui = localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Flipbook"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local FlipbookCore = require("@workspace/flipbook-core/src")

FlipbookCore.createEmbeddedFlipbookApp(screenGui, {
	initialStoryPath = launchData.initialStoryPath,
	storyRoot = resolveStoryRoot(launchData),
})

print(`embedded Flipbook client script successfully initialized in {os.clock() - startClock}s`)
