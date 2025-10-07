--!nonstrict

local UGCValidationService = game:GetService("UGCValidationService")
local FFlagUGCValidationAddThumbnailFrustumCheckingv2 =
	game:DefineFastFlag("UGCValidationAddThumbnailFrustumCheckingv2", false)
-- validates that if ThumbnailConfiguration exists, ThumbnailConfiguration.ThumbnailCameraTarget.Value is set to the handle

local root = script.Parent.Parent

local Types = require(root.util.Types)

local Analytics = require(root.Analytics)

local function validateThumbnailConfiguration(
	accessory: Instance,
	handle: BasePart,
	meshInfo: Types.MeshInfo,
	meshScale: Vector3,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local thumbnailConfiguration = accessory:FindFirstChild("ThumbnailConfiguration")

	if thumbnailConfiguration then
		-- if ThumbnailConfiguration is present, validateInstanceTree verifies ThumbnailCameraTarget also exists
		local thumbnailCameraTarget = thumbnailConfiguration:FindFirstChild("ThumbnailCameraTarget") :: ObjectValue
		if thumbnailCameraTarget.Value ~= handle then
			Analytics.reportFailure(
				Analytics.ErrorType.validateThumbnailConfiguration_InvalidTarget,
				nil,
				validationContext
			)
			return false,
				{
					string.format(
						"Invalid target asset for thumbnail generation. Expected it to be '%s'.",
						handle:GetFullName()
					),
				}
		end
		-- check the frustum of the camera when taking snapshots now
		if
			game:GetEngineFeature("EngineUGCValidateThumbnailerMeshInFrustum")
			and FFlagUGCValidationAddThumbnailFrustumCheckingv2
		then
			local target = thumbnailCameraTarget.Value :: BasePart
			local handleCF = target.CFrame
			local thumbnailCameraValue = thumbnailConfiguration:FindFirstChild("ThumbnailCameraValue") :: CFrameValue
			local cameraCF = handleCF * thumbnailCameraValue.Value
			if
				UGCValidationService:CheckEditableMeshInCameraFrustum(
					meshInfo.editableMesh,
					meshScale,
					handleCF,
					cameraCF
				) == false
			then
				Analytics.reportFailure(
					Analytics.ErrorType.validateThumbnailConfiguration_OutsideView,
					nil,
					validationContext
				)
				return false,
					{
						string.format(
							"Asset '%s' is positioned outside the thumbnail camera view. You need to reposition the asset at the center of the camera view and try again.",
							meshInfo.fullName
						),
					}
			end
		end
	end

	return true
end

return validateThumbnailConfiguration
