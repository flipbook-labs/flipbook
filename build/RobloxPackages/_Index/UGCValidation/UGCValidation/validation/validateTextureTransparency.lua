--[[
	Validates that the texture is opaque.
]]

local root = script.Parent.Parent

local Analytics = require(root.Analytics)
local Types = require(root.util.Types)

local function getIsOpaque(image: EditableImage)
	local pixels = image:ReadPixelsBuffer(Vector2.new(0, 0), image.Size)
	for i = 0, buffer.len(pixels) - 1, 4 do
		local a = buffer.readu8(pixels, i + 3)
		if a < 255 then
			return false
		end
	end

	return true
end

local function validateTextureTransparency(
	textureInfo: Types.TextureInfo,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	if not textureInfo.editableImage then
		Analytics.reportFailure(
			Analytics.ErrorType.validateTextureTransparency_InvalidTextureId,
			nil,
			validationContext
		)
		return false,
			{
				string.format(
					"Invalid textureID used in mesh '%s'. Make sure the texture exists and try again.",
					textureInfo.fullName
				),
			}
	end

	local isOpaque = getIsOpaque(textureInfo.editableImage)
	if not isOpaque then
		Analytics.reportFailure(
			Analytics.ErrorType.validateTextureTransparency_TransparentTexture,
			nil,
			validationContext
		)
		return false,
			{
				string.format("Texture %s is not fully opaque. Please use an opaque texture.", textureInfo.fullName),
			}
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return true
end

return validateTextureTransparency
