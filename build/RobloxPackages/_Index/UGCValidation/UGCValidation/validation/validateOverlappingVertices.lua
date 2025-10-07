local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local Analytics = require(root.Analytics)

local function validateOverlappingVertices(
	meshInfo: Types.MeshInfo,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local isServer = validationContext.isServer

	local success, result = pcallDeferred(function()
		return UGCValidationService:ValidateEditableMeshOverlappingVertices(meshInfo.editableMesh)
	end, validationContext)

	if not success then
		if nil ~= isServer and isServer then
			-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
			-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
			-- which would mean the asset failed validation
			error(
				string.format(
					"Failed to execute overlapping mesh vertex check for '%s'. Make sure mesh exists and try again.",
					meshInfo.fullName
				)
			)
		end
		Analytics.reportFailure(Analytics.ErrorType.validateOverlappingVertices_FailedToExecute, nil, validationContext)
		return false,
			{
				string.format(
					"Failed to execute overlapping mesh vertex check for '%s'. Make sure mesh exists and try again.",
					meshInfo.fullName
				),
			}
	end

	if not result then
		Analytics.reportFailure(
			Analytics.ErrorType.validateOverlappingVertices_OverlappingVertices,
			nil,
			validationContext
		)
		return false,
			{
				string.format(
					"Detected two or more vertices in model mesh '%s' sharing near identical positions. You need to position vertices further apart from each other.",
					meshInfo.fullName
				),
			}
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return true
end

return validateOverlappingVertices
