local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StudioService = if RunService:IsStudio() then game:GetService("StudioService") else nil

local function getLocalUserId(): number
	if StudioService then
		return StudioService:GetUserId()
	end
	if Players.LocalPlayer then
		return Players.LocalPlayer.UserId
	end
	return -1
end

return getLocalUserId
