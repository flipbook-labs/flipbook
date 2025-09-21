local Players = game:GetService("Players")

local tryGetService = require("@root//Permissions/tryGetService")
local StudioService = tryGetService("StudioService") :: StudioService?

local function getClientUserId(): string?
	if StudioService then
		return tostring(StudioService:GetUserId())
	else
		if Players.LocalPlayer then
			return tostring(Players.LocalPlayer.UserId)
		end
	end
	return nil
end

return getClientUserId
