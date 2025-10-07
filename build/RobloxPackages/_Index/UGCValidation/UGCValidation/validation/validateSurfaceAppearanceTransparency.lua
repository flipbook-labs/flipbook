--[[
	validateSurfaceAppearanceTransparency.lua checks that for all MeshPart descendants, if a SurfaceAppearance exists the AplhaMode is Enum.AlphaMode.Overlay and the NormalMap texture is opaque.
]]

local root = script.Parent.Parent

local Analytics = require(root.Analytics)
local Constants = require(root.Constants)
local Types = require(root.util.Types)

local validateTextureTransparency = require(root.validation.validateTextureTransparency)

local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)
local getEditableImageFromContext = require(root.util.getEditableImageFromContext)
local ParseContentIds = require(root.util.ParseContentIds)

local FORCE_OPAQUE_TEXTURES = {
	ColorMap = true,
	NormalMap = true,
}

local function validateSurfaceAppearanceTransparency(
	instance: Instance,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local allDescendants: { Instance } = instance:GetDescendants()
	table.insert(allDescendants, instance)

	local reasonsAccumulator = FailureReasonsAccumulator.new()
	for _, descendant in allDescendants do
		if not descendant:IsA("MeshPart") then
			continue
		end

		local surfaceAppearance = descendant:FindFirstChildWhichIsA("SurfaceAppearance")
		if not surfaceAppearance then
			continue
		end

		local alphaMode = surfaceAppearance.AlphaMode
		if alphaMode ~= Enum.AlphaMode.Overlay then
			Analytics.reportFailure(
				Analytics.ErrorType.validateSurfaceAppearances_InvalidAlphaMode,
				nil,
				validationContext
			)
			reasonsAccumulator:updateReasons(false, {
				`SurfaceAppearance ({(descendant :: Instance):GetFullName()}) has an invalid AlphaMode. Expected Enum.AlphaMode.Overlay`,
			})
		end

		local allTextures =
			ParseContentIds.parse(surfaceAppearance, Constants.TEXTURE_CONTENT_ID_FIELDS, validationContext)

		for _, data in allTextures do
			if not FORCE_OPAQUE_TEXTURES[data.fieldName] then
				continue
			end

			local textureInfo = {
				fullName = data.instance:GetFullName(),
				fieldName = data.fieldName,
				contentId = data.instance[data.fieldName],
			} :: Types.TextureInfo

			local getEditableImageSuccess, editableImage =
				getEditableImageFromContext(data.instance, data.fieldName, validationContext)
			if not getEditableImageSuccess then
				return false, { "Failed to load texture data" }
			end
			textureInfo.editableImage = editableImage :: EditableImage

			reasonsAccumulator:updateReasons(validateTextureTransparency(textureInfo, validationContext))
		end
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return reasonsAccumulator:getFinalResults()
end

return validateSurfaceAppearanceTransparency
