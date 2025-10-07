local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Analytics = require(root.Analytics)

local Types = require(root.util.Types)

local function validateMisMatchUV(
	innerCageMeshInfo: Types.MeshInfo,
	outerCageMeshInfo: Types.MeshInfo,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	assert(innerCageMeshInfo.context == outerCageMeshInfo.context)

	local success, result = pcall(function()
		return UGCValidationService:ValidateEditableMeshMisMatchUV(
			innerCageMeshInfo.editableMesh,
			outerCageMeshInfo.editableMesh
		)
	end)

	if not success then
		Analytics.reportFailure(Analytics.ErrorType.validateMisMatchUV_FailedToExecute, nil, validationContext)
		return false,
			{
				string.format(
					"Failed to execute UV mismatch check for '%s'. Make sure UV map exists and try again.",
					innerCageMeshInfo.context
				),
			}
	end

	if not result then
		Analytics.reportFailure(Analytics.ErrorType.validateMisMatchUV_UVMismatch, nil, validationContext)
		return false,
			{
				string.format(
					"Inner and Outer cage UV for '%s' are mismatched. The Roblox provided cage template should be used to create inner and outer cages with no modifications to the UV map.",
					innerCageMeshInfo.context
				),
			}
	end

	return true
end

return validateMisMatchUV
