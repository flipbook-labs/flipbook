local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Analytics = require(root.Analytics)

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local function validateCageMeshIntersection(
	innerCageMeshInfo: Types.MeshInfo,
	outerCageMeshInfo: Types.MeshInfo,
	meshInfo: Types.MeshInfo,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	assert(validationContext.assetTypeEnum, "validationContext.assetTypeEnum is required")

	local assetTypeEnum = validationContext.assetTypeEnum
	if not meshInfo.editableMesh then
		Analytics.reportFailure(
			Analytics.ErrorType.validateCageMeshIntersection_InvalidRefMeshId,
			nil,
			validationContext
		)
		return false,
			{
				string.format(
					"The meshId reference for cage '%s' is invalid or doesn't exist. Please, verify you are using a valid mesh asset and try again.",
					meshInfo.fullName
				),
			}
	end

	local success, checkIntersection, checkIrrelevantCageModified, checkOuterCageFarExtendedFromMesh, checkAverageOuterCageToMeshVertDistances = pcallDeferred(
		function()
			return UGCValidationService:ValidateEditableMeshCageMeshIntersection(
				innerCageMeshInfo.editableMesh,
				outerCageMeshInfo.editableMesh,
				meshInfo.editableMesh
			)
		end,
		validationContext
	)

	if not success then
		Analytics.reportFailure(
			Analytics.ErrorType.validateCageMeshIntersection_FailedToExecute,
			nil,
			validationContext
		)
		return false,
			{
				string.format(
					"Failed to execute cage intersection detection for '%s'. Make sure the cage mesh exists and try again.",
					meshInfo.fullName
				),
			}
	end

	local reasons = {}
	local result = true
	if not checkIntersection then
		result = false
		Analytics.reportFailure(Analytics.ErrorType.validateCageMeshIntersection_Intersection, nil, validationContext)
		table.insert(
			reasons,
			string.format(
				"There are cage vertices inside the layered accessory mesh '%s', which could lead to interpenetration issues during fitting. You need to edit the cage mesh to fix this intersection issue.",
				outerCageMeshInfo.context
			)
		)
	end

	if not checkIrrelevantCageModified then
		result = false
		Analytics.reportFailure(
			Analytics.ErrorType.validateCageMeshIntersection_IrrelevantCageModified,
			nil,
			validationContext
		)
		table.insert(
			reasons,
			string.format(
				"Outer cage of '%s' has mesh edits on regions that don't correspond to its current asset type '%s' (i.e. edits on the lower leg cages when asset type is set to 'Head'). You need to check the asset type for the layered accessory '%s'.",
				outerCageMeshInfo.fullName,
				assetTypeEnum.Name,
				outerCageMeshInfo.context
			)
		)
	end

	if not checkOuterCageFarExtendedFromMesh then
		result = false
		Analytics.reportFailure(
			Analytics.ErrorType.validateCageMeshIntersection_OuterCageFarExtendedFromMesh,
			nil,
			validationContext
		)
		table.insert(
			reasons,
			string.format(
				"Outer cage of '%s' has mesh edits that place vertices too far away from the model mesh. You need to edit the cage vertices to be closer to the model.",
				outerCageMeshInfo.fullName
			)
		)
	end

	if not checkAverageOuterCageToMeshVertDistances then
		result = false
		Analytics.reportFailure(
			Analytics.ErrorType.validateCageMeshIntersection_AverageOuterCageToMeshVertDistances,
			nil,
			validationContext
		)
		table.insert(
			reasons,
			string.format(
				"The average distance between the layered accessory '%s' and its outer cage is too large. You need to edit the cage mesh to be closer to the accessory.",
				outerCageMeshInfo.context
			)
		)
	end

	return result, reasons
end

return validateCageMeshIntersection
