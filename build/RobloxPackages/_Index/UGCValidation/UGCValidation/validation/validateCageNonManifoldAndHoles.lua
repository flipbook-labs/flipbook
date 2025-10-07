local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Types = require(root.util.Types)

local Analytics = require(root.Analytics)

local function validateCageNonManifoldAndHoles(
	meshInfo: Types.MeshInfo,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local success, checkNonManifold, checkCageHoles = pcall(function()
		return UGCValidationService:ValidateEditableMeshCageNonManifoldAndHoles(meshInfo.editableMesh)
	end)

	if not success then
		Analytics.reportFailure(
			Analytics.ErrorType.validateCageNonManifoldAndHoles_FailedToExecute,
			nil,
			validationContext
		)
		return false,
			{
				string.format(
					"Failed to execute cage non-manifold check for '%s'. Make sure cage mesh exists and try again.",
					meshInfo.fullName
				),
			}
	end

	local reasons = {}
	local result = true
	if not checkNonManifold then
		result = false
		Analytics.reportFailure(Analytics.ErrorType.validateCageNonManifoldAndHoles_NonManifold, nil, validationContext)
		table.insert(
			reasons,
			string.format(
				"'%s' is non-manifold (i.e. there are edges with 3 or more incident faces). Some vertices are likely too close and welded together as a single vertex causing edges to collapse into a non-manifold. You need to edit the cage mesh so that vertices aren't too close together.",
				meshInfo.fullName
			)
		)
	end

	if not checkCageHoles then
		result = false
		Analytics.reportFailure(Analytics.ErrorType.validateCageNonManifoldAndHoles_CageHoles, nil, validationContext)
		table.insert(
			reasons,
			string.format(
				"'%s' is not watertight (i.e. detected holes in the mesh). You need to edit the mesh and close the holes (may leave eyes and mouth areas open when applicable).",
				meshInfo.fullName
			)
		)
	end

	return result, reasons
end

return validateCageNonManifoldAndHoles
