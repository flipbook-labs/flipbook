--[[
	check whether the underlying meshID would result in meshpart.HasSkinnedMesh to be true, which is not supported for rigid accessories
]]

local root = script.Parent.Parent

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)
local Analytics = require(root.Analytics)

local UGCValidationService = game:GetService("UGCValidationService")

local function validateRigidMeshNotSkinned(
	meshID: string?,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local success, hasSkinningData = pcallDeferred(function()
		return (UGCValidationService :: any):DoesMeshHaveSkinningData(meshID)
	end, validationContext)

	if not success then
		Analytics.reportFailure(Analytics.ErrorType.validateRigidMeshSkinning_FailedToDownload, nil, validationContext)

		return false, { "Could not verify underlying mesh data. Please try again or make a bug report." }
	elseif hasSkinningData then
		Analytics.reportFailure(Analytics.ErrorType.validateRigidMeshSkinning_BonesFoundInMesh, nil, validationContext)
		return false,
			{
				"This accessory mesh has underlying skinning data, which is not supported for rigid accessories. Ensure that you are not importing bones when loading the mesh into Studio.",
			}
	end

	return true
end

return validateRigidMeshNotSkinned
