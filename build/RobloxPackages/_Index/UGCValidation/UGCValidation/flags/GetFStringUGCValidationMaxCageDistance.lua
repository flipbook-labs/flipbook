--[[
	declare and retrieve the FStringUGCValidationMaxCageDistance fast flag
]]

game:DefineFastString("UGCValidationMaxCageDistance", "0.3")

local GetFStringUGCValidationMaxCageDistance = {}

function GetFStringUGCValidationMaxCageDistance.asString(): string
	return game:GetFastString("UGCValidationMaxCageDistance")
end

function GetFStringUGCValidationMaxCageDistance.asNumber(): number
	return tonumber(GetFStringUGCValidationMaxCageDistance.asString()) :: number
end

return GetFStringUGCValidationMaxCageDistance
