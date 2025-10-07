--[[
	validateCoplanarIntersection.lua calculates whether any triangles in a mesh intersect on the same plane.
]]

local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local getFIntMaxCoplanarIntersectionsPercentage = require(root.flags.getFIntMaxCoplanarIntersectionsPercentage)

local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)

local Analytics = require(root.Analytics)

local function getTriangleCount(
	meshInfo: Types.MeshInfo,
	validationContext: Types.ValidationContext,
	isServer: boolean?
): (boolean, { string }?, number?)
	local success, triangleCount = pcallDeferred(function()
		return UGCValidationService:GetEditableMeshTriCount(meshInfo.editableMesh :: EditableMesh)
	end, validationContext)

	if not success then
		local errorString =
			string.format("Failed to load model mesh %s. Make sure the mesh exists and try again.", meshInfo.fullName)
		Analytics.reportFailure(
			Analytics.ErrorType.validateCoplanarIntersection_FailedToExecute,
			nil,
			validationContext
		)
		if nil ~= isServer and isServer then
			-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
			-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
			-- which would mean the asset failed validation
			error(errorString)
		end
		return false, { errorString }
	end
	return true, nil, triangleCount
end

local function validateCoplanarIntersection(
	meshInfo: Types.MeshInfo,
	meshScale: Vector3,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local isServer = validationContext.isServer

	local triangleCountSuccess, triangleCountErrors, triangleCount =
		getTriangleCount(meshInfo, validationContext, isServer)
	if not triangleCountSuccess then
		return false, triangleCountErrors
	end

	local maxAllowedIntersections =
		math.floor((getFIntMaxCoplanarIntersectionsPercentage() / 100) * (triangleCount :: number))

	local success, isOverLimit = pcallDeferred(function()
		return (UGCValidationService :: any):IsEditableMeshNumCoplanarIntersectionsOverLimit(
			meshInfo.editableMesh,
			maxAllowedIntersections,
			meshScale,
			true
		)
	end, validationContext)

	if not success then
		local errorString = string.format(
			"Failed to execute coplanar triangle intersection check for '%s'. Make sure mesh exists and try again.",
			meshInfo.fullName
		)
		if nil ~= isServer and isServer then
			-- there could be many reasons that an error occurred, the asset is not necessarilly incorrect, we just didn't get as
			-- far as testing it, so we throw an error which means the RCC will try testing the asset again, rather than returning false
			-- which would mean the asset failed validation
			error(errorString)
		end
		Analytics.reportFailure(
			Analytics.ErrorType.validateCoplanarIntersection_FailedToExecute,
			nil,
			validationContext
		)
		return false, { errorString }
	end

	if isOverLimit then
		Analytics.reportFailure(
			Analytics.ErrorType.validateCoplanarIntersection_CoplanarIntersection,
			nil,
			validationContext
		)
		return false,
			{
				string.format(
					"Detected too many coplanar triangles intersecting in model mesh '%s'. The maximum is %d intersections in a %d triangle mesh. Edit your mesh to reduce the number of coplanar triangle intersections.",
					meshInfo.fullName,
					maxAllowedIntersections,
					triangleCount :: number
				),
			}
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return true
end

return validateCoplanarIntersection
