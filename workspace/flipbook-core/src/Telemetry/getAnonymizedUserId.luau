local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StudioService = if RunService:IsStudio() then game:GetService("StudioService") else nil

local sha256 = require("@pkg/sha256")

local function getLocalUserId(): number
	if StudioService then
		return StudioService:GetUserId()
	end
	if Players.LocalPlayer then
		return Players.LocalPlayer.UserId
	end
	return -1
end

--[[
	The events we send to the backend need some persistent identifier so we can
	group them by the user they come from. However, we do not collect PII so we
	first need to anonymize the UserId before sending it off. That's what this
	function is for.
]]
local function getAnonymizedUserId(): string
	local plainUserId = getLocalUserId()
	local hash = sha256(tostring(plainUserId))
	return hash
end

return getAnonymizedUserId
