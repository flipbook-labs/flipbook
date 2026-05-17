local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tagRuntime = require("@root/Embedding/runtime/tagRuntime")

local DEFAULT_CONTAINER_NAME = "Flipbook"

local function getPluginRoot(): Instance
	local workspaceFolder = script:FindFirstAncestor("workspace")
	assert(workspaceFolder ~= nil, "Could not locate Flipbook workspace folder")

	local pluginRoot = workspaceFolder.Parent
	assert(pluginRoot ~= nil, "Could not locate Flipbook plugin root")

	return pluginRoot
end

local function getDefaultTarget(): Instance?
	return ReplicatedStorage:FindFirstChild(DEFAULT_CONTAINER_NAME)
end

local function getTargetLocation(target: Instance?): (Instance, string)
	if target == nil then
		return ReplicatedStorage, DEFAULT_CONTAINER_NAME
	end

	local parent = target.Parent
	if parent == nil then
		return target, DEFAULT_CONTAINER_NAME
	end

	return parent, target.Name
end

local function embedIntoExperience(target: Instance?)
	local pluginRoot = getPluginRoot()
	local targetInstance = target or getDefaultTarget()
	local parent, name = getTargetLocation(targetInstance)

	if targetInstance ~= nil and targetInstance.Parent == parent then
		targetInstance:Destroy()
	end

	local embeddedFlipbook = pluginRoot:Clone()
	embeddedFlipbook.Name = name
	embeddedFlipbook.Parent = parent

	tagRuntime(embeddedFlipbook)

	return embeddedFlipbook
end

return embedIntoExperience
