--!nonstrict

local root = script.Parent.Parent

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local Analytics = require(root.Analytics)

local UGCValidationService = game:GetService("UGCValidationService")

local function validateMeshTriangleArea(
	meshInfo: Types.MeshInfo,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local isServer = if validationContext then validationContext.isServer else nil

	local success, result = pcallDeferred(function()
		return UGCValidationService:ValidateEditableMeshTriangleArea(meshInfo.editableMesh)
	end, validationContext)

	if not success then
		Analytics.reportFailure(Analytics.ErrorType.validateMeshTriangleArea_FailedToLoadMesh, nil, validationContext)
		if isServer then
			error(
				string.format("Failed to load model mesh %s. Make sure mesh exists and try again.", meshInfo.fullName)
			)
		end
		return false,
			{
				string.format("Failed to load model mesh %s. Make sure mesh exists and try again.", meshInfo.fullName),
			}
	end

	if not result then
		Analytics.reportFailure(Analytics.ErrorType.validateMeshTriangleArea_NoArea, nil, validationContext)
		return false,
			{
				string.format(
					"Detected zero-area triangle in model mesh %s. You need to edit the mesh to remove zero-area triangles.",
					meshInfo.fullName
				),
			}
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return true
end

return validateMeshTriangleArea
