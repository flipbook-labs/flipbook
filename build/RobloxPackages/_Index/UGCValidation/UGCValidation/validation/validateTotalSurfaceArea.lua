--[[
	validateTotalSurfaceArea.lua calculates the total surface area of a mesh and compares it to the maximum allowed surface area.
]]

local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local getFIntMaxTotalSurfaceArea = require(root.flags.getFIntMaxTotalSurfaceArea)

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local Analytics = require(root.Analytics)

local function validateTotalSurfaceArea(
	meshInfo: Types.MeshInfo,
	meshScale: Vector3,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local isServer = validationContext.isServer

	local success, result = pcallDeferred(function()
		return (UGCValidationService :: any):CalculateEditableMeshTotalSurfaceArea(meshInfo.editableMesh, meshScale)
	end, validationContext)

	if not success then
		local errorString = string.format(
			"Failed to execute max total surface area check for '%s'. Make sure mesh exists and try again.",
			meshInfo.fullName
		)
		if nil ~= isServer and isServer then
			-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
			-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
			-- which would mean the asset failed validation
			error(errorString)
		end
		Analytics.reportFailure(Analytics.ErrorType.validateTotalSurfaceArea_FailedToExecute, nil, validationContext)
		return false, { errorString }
	end

	if result > getFIntMaxTotalSurfaceArea() then
		Analytics.reportFailure(
			Analytics.ErrorType.validateTotalSurfaceArea_maxTotalSurfaceAreaExceeded,
			nil,
			validationContext
		)
		return false,
			{
				string.format(
					"The total surface area of model mesh '%s' is %.2f, it cannot be greater than %d. You must reduce the number and/or size of all triangles.",
					meshInfo.fullName,
					result,
					getFIntMaxTotalSurfaceArea()
				),
			}
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return true
end

return validateTotalSurfaceArea
