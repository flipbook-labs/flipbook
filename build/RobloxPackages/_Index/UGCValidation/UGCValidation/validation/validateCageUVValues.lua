--!nonstrict
--change above to string after latest robloxdev-cli has new function `UGCValidationService:ValidateUVValuesInReference()`

--[[
	validateCageUVs.lua checks that WrapTarget cage meshes have the correct UV values based on the template
]]

local root = script.Parent.Parent

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local WRAP_TARGET_CAGE_REFERENCE_VALUES = require(root.WrapTargetCageUVReferenceValues)

local getEngineFeatureEngineUGCValidateBodyParts = require(root.flags.getEngineFeatureEngineUGCValidateBodyParts)

local Analytics = require(root.Analytics)

local UGCValidationService = game:GetService("UGCValidationService")

local function validateCageUVValues(
	meshInfo: Types.MeshInfo,
	wrapTarget: WrapTarget,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local isServer = validationContext.isServer
	if not getEngineFeatureEngineUGCValidateBodyParts() then
		return true
	end

	local referenceUVValues = assert(
		WRAP_TARGET_CAGE_REFERENCE_VALUES[(wrapTarget.Parent :: Instance).Name],
		"WrapTarget is not parented to a MeshPart"
	)

	local success, result = pcallDeferred(function()
		return UGCValidationService:ValidateEditableMeshUVValuesInReference(referenceUVValues, meshInfo.editableMesh)
	end, validationContext)

	if not success then
		Analytics.reportFailure(Analytics.ErrorType.validateCageUVValues_FailedToLoadMesh, nil, validationContext)
		local errorMsg = string.format(
			"Failed to load UVs for '%s'. Make sure the UV map exists and try again.",
			wrapTarget:GetFullName()
		)
		if isServer then
			-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
			-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
			-- which would mean the asset failed validation
			error(errorMsg)
		end
		return false, { errorMsg }
	end

	if not result then
		Analytics.reportFailure(Analytics.ErrorType.validateCageUVValues_UnexpectedUVValue, nil, validationContext)
		return false,
			{
				string.format(
					"Found invalid UV value outside [0, 1] range for '%s'. You need to edit the UV map to fix this issue.",
					wrapTarget:GetFullName()
				),
			}
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return true
end

return validateCageUVValues
