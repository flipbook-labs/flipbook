--[[
	pretty print Vector3
]]

local root = script.Parent.Parent

local getFFlagUGCValidatePreciseVectorPrint = require(root.flags.getFFlagUGCValidatePreciseVectorPrint)

local allFormats = {}

local function prettyPrintVector3(v: Vector3, decimalPlacesOpt: number?): string
	if getFFlagUGCValidatePreciseVectorPrint() then
		local decimalPlaces = if decimalPlacesOpt then decimalPlacesOpt :: number else 2
		if not allFormats[decimalPlaces] then
			local decimalPlacesFormat = string.format("%%.%df", decimalPlaces)
			allFormats[decimalPlaces] =
				string.format("%s, %s, %s", decimalPlacesFormat, decimalPlacesFormat, decimalPlacesFormat)
		end
		return string.format(allFormats[decimalPlaces], v.X, v.Y, v.Z)
	else
		return string.format("%.2f, %.2f, %.2f", v.X, v.Y, v.Z)
	end
end

return prettyPrintVector3
