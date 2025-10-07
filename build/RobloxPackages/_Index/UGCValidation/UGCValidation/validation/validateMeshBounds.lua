local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Types = require(root.util.Types)

local getFFlagUGCValidatePartSizeWithinRenderSizeLimits =
	require(root.flags.getFFlagUGCValidatePartSizeWithinRenderSizeLimits)
local Analytics = require(root.Analytics)

local DEFAULT_OFFSET = Vector3.new(0, 0, 0)

local FFlagUGCValidationScaleMinimum = game:DefineFastFlag("UGCValidationScaleMinimum", false)
local FIntUGCValidationScaleMinimumThousandths = game:DefineFastInt("UGCValidationScaleMinimumThousandths", 10) -- 1 = 0.001

local function pointInBounds(worldPos, boundsCF, boundsSize)
	local objectPos = boundsCF:PointToObjectSpace(worldPos)
	return objectPos.X >= -boundsSize.X / 2
		and objectPos.X <= boundsSize.X / 2
		and objectPos.Y >= -boundsSize.Y / 2
		and objectPos.Y <= boundsSize.Y / 2
		and objectPos.Z >= -boundsSize.Z / 2
		and objectPos.Z <= boundsSize.Z / 2
end

local function isSizeWithinBounds(part: BasePart, boundsSize)
	return part.Size.X <= boundsSize.X and part.Size.Y <= boundsSize.Y and part.Size.Z <= boundsSize.Z
end

local function truncate(number: number): number
	return math.floor(number * 100) / 100
end

local function getErrors(name: string, assetType: string, v: Vector3): { string }
	return {
		string.format(
			"%s has size larger than max allowed bounding size. The max size for type %s is [%.2f, %.2f, %.2f]",
			name,
			assetType,
			truncate(v.X),
			truncate(v.Y),
			truncate(v.Z)
		),
	}
end

local function validateMeshBounds(
	handle: BasePart,
	attachment: Attachment,
	meshInfo: Types.MeshInfo,
	meshScale: Vector3,
	boundsInfo: any,
	assetTypeName: string,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local isServer = validationContext.isServer
	local boundsSize = boundsInfo.size
	local boundsOffset = boundsInfo.offset or DEFAULT_OFFSET
	local boundsCF = handle.CFrame * attachment.CFrame * CFrame.new(boundsOffset)

	if
		handle.Position.X > 10000
		or handle.Position.X < -10000
		or handle.Position.Y > 10000
		or handle.Position.Y < -10000
		or handle.Position.Z > 10000
		or handle.Position.Z < -10000
	then
		return false, { "Position is outside of bounds" }
	end
	if
		boundsCF.Position.X > 10000
		or boundsCF.Position.X < -10000
		or boundsCF.Position.Y > 10000
		or boundsCF.Position.Y < -10000
		or boundsCF.Position.Z > 10000
		or boundsCF.Position.Z < -10000
	then
		return false, { "Position is outside of bounds" }
	end

	if FFlagUGCValidationScaleMinimum then
		if
			meshScale.X < FIntUGCValidationScaleMinimumThousandths / 1000
			or meshScale.Y < FIntUGCValidationScaleMinimumThousandths / 1000
			or meshScale.Z < FIntUGCValidationScaleMinimumThousandths / 1000
		then
			return false, { "Mesh scale is too small" }
		end
	end

	local success, verts = pcall(function()
		return UGCValidationService:GetEditableMeshVerts(meshInfo.editableMesh)
	end)
	if not success then
		Analytics.reportFailure(Analytics.ErrorType.validateMeshBounds_FailedToLoadMesh, nil, validationContext)
		if nil ~= isServer and isServer then
			-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
			-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
			-- which would mean the asset failed validation
			error(
				string.format(
					"Failed to load body part mesh %s. Make sure body part exists and try again.",
					meshInfo.fullName
				)
			)
		end
		return false,
			{
				string.format(
					"Failed to load body part mesh %s. Make sure body part exists and try again.",
					meshInfo.fullName
				),
			}
	end

	for _, vertPos in pairs(verts) do
		local worldPos = handle.CFrame:PointToWorldSpace(vertPos * meshScale)
		if not pointInBounds(worldPos, boundsCF, boundsSize) then
			Analytics.reportFailure(Analytics.ErrorType.validateMeshBounds_TooLarge, nil, validationContext)
			return false, getErrors(meshInfo.context :: string, assetTypeName, boundsSize)
		end
	end

	if getFFlagUGCValidatePartSizeWithinRenderSizeLimits() then
		if not isSizeWithinBounds(handle, boundsSize) then
			Analytics.reportFailure(Analytics.ErrorType.validateMeshBounds_TooLarge, nil, validationContext)
			return false, getErrors(handle:GetFullName(), assetTypeName, boundsSize)
		end
	end

	return true
end

return validateMeshBounds
