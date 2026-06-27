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

local prefix = `[{script.Name}]`

local localPlayer = Players.LocalPlayer
if localPlayer == nil then
	return
end

local startClock = os.clock()
print(`{prefix} starting...`)

print(`{prefix} setting up Flipbook UI...`)
local playerGui = localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Flipbook"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local FlipbookCore = require("@workspace/flipbook-core/src")

FlipbookCore.createEmbeddedFlipbookApp(screenGui)

print(`{prefix} successfully initialized in {os.clock() - startClock}s`)
