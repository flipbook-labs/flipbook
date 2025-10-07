--[[
	validateAssetBounds.lua checks the entire asset is not to big or too small
]]

local root = script.Parent.Parent

local Analytics = require(root.Analytics)
local Constants = require(root.Constants)
local Types = require(root.util.Types)
local BoundsCalculator = require(root.util.BoundsCalculator)

local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)

local validateScaleType = require(root.validation.validateScaleType)

local function forEachMeshPart(
	fullBodyAssets: Types.AllBodyParts?,
	inst: Instance?,
	assetTypeEnum: Enum.AssetType?,
	func: (meshHandle: MeshPart) -> boolean
)
	local isSingleInstance = inst and assetTypeEnum
	assert((nil ~= fullBodyAssets) ~= (nil ~= isSingleInstance)) -- one, but not both, should have a value

	if fullBodyAssets then
		for _, meshHandle in fullBodyAssets :: Types.AllBodyParts do
			if not func(meshHandle :: MeshPart) then
				return false
			end
		end
	else
		local assetInfo = Constants.ASSET_TYPE_INFO[assetTypeEnum :: Enum.AssetType]
		assert(assetInfo)

		if Enum.AssetType.DynamicHead == assetTypeEnum :: Enum.AssetType then
			return func(inst :: MeshPart)
		else
			for subPartName in pairs(assetInfo.subParts) do
				local meshHandle: MeshPart? = (inst :: Instance):FindFirstChild(subPartName) :: MeshPart
				assert(meshHandle)
				if not func(meshHandle) then
					return false
				end
			end
		end
	end
	return true
end

local function getScaleType(
	fullBodyAssets: Types.AllBodyParts?,
	inst: Instance?,
	assetTypeEnum: Enum.AssetType?,
	validationContext: Types.ValidationContext
): (boolean, { string }?, string?)
	local isSingleInstance = inst and assetTypeEnum
	assert((nil ~= fullBodyAssets) ~= (nil ~= isSingleInstance)) -- one, but not both, should have a value

	local prevPartScaleType = nil
	local result = forEachMeshPart(fullBodyAssets, inst, assetTypeEnum, function(meshHandle: MeshPart)
		local scaleType: StringValue? = meshHandle:FindFirstChild("AvatarPartScaleType") :: StringValue
		assert(scaleType) -- expected parts have been checked for existance before calling this function

		if not prevPartScaleType then
			prevPartScaleType = scaleType :: StringValue
		else
			return prevPartScaleType.Value == scaleType.Value
		end
		return true
	end)
	if not result then
		Analytics.reportFailure(
			Analytics.ErrorType.validateAssetBounds_InconsistentAvatarPartScaleType,
			nil,
			validationContext
		)
		return false,
			{
				"All MeshParts must have the same value in their AvatarPartScaleType child. Please verify the values match.",
			},
			nil
	end

	local success, reasons = validateScaleType(prevPartScaleType, validationContext)
	return success, reasons, if success then prevPartScaleType.Value else nil
end

local function validateMinBoundsInternal(
	minSize: Vector3,
	assetTypeEnum: Enum.AssetType?,
	minMaxBounds: Types.BoundsData,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local reasonsAccumulator = FailureReasonsAccumulator.new()

	local failureMessageNotLargeEnough =
		"%s meshes %s axis size of '%.2f' is smaller than the min allowed bounding box %s axis size of '%.2f'. You need to scale up the meshes."

	local hasAnalyticsBeenReported = false

	local meshSize = minMaxBounds.maxMeshCorner :: Vector3 - minMaxBounds.minMeshCorner :: Vector3
	for _, dimension in { "X", "Y", "Z" } do
		local assetSizeOnAxis = (meshSize :: any)[dimension]
		local minSizeOnAxis = (minSize :: any)[dimension]

		local isMeshLargeEnough = assetSizeOnAxis >= minSizeOnAxis
		if not isMeshLargeEnough and not hasAnalyticsBeenReported then
			Analytics.reportFailure(Analytics.ErrorType.validateAssetBounds_AssetSizeTooSmall, nil, validationContext)
			hasAnalyticsBeenReported = true
		end

		reasonsAccumulator:updateReasons(isMeshLargeEnough, {
			string.format(
				failureMessageNotLargeEnough,
				if assetTypeEnum then (assetTypeEnum :: Enum.AssetType).Name else "Full body",
				dimension,
				assetSizeOnAxis,
				dimension,
				minSizeOnAxis
			),
		})
	end
	return reasonsAccumulator:getFinalResults()
end

local function validateMaxBoundsInternal(
	maxSize: Vector3,
	assetTypeEnum: Enum.AssetType?,
	minMaxBounds: Types.BoundsData,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local reasonsAccumulator = FailureReasonsAccumulator.new()

	local failureMessageNotSmallEnough =
		"%s meshes and joints %s axis size of '%.2f' is larger than the max allowed bounding box %s axis size of '%.2f'. You need to scale down the meshes/joints"

	local hasAnalyticsBeenReported = false

	local overallSize = minMaxBounds.maxOverall :: Vector3 - minMaxBounds.minOverall :: Vector3
	for _, dimension in { "X", "Y", "Z" } do
		local assetSizeOnAxis = (overallSize :: any)[dimension]
		local maxSizeOnAxis = (maxSize :: any)[dimension]

		local isMeshSmallEnough = assetSizeOnAxis <= maxSizeOnAxis
		if not isMeshSmallEnough and not hasAnalyticsBeenReported then
			Analytics.reportFailure(Analytics.ErrorType.validateAssetBounds_AssetSizeTooBig, nil, validationContext)
			hasAnalyticsBeenReported = true
		end

		reasonsAccumulator:updateReasons(isMeshSmallEnough, {
			string.format(
				failureMessageNotSmallEnough,
				if assetTypeEnum then (assetTypeEnum :: Enum.AssetType).Name else "Full body",
				dimension,
				assetSizeOnAxis,
				dimension,
				maxSizeOnAxis
			),
		})
	end
	return reasonsAccumulator:getFinalResults()
end

local function validateAssetBounds(
	fullBodyAssets: Types.AllBodyParts?,
	inst: Instance?,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local assetTypeEnum = validationContext.assetTypeEnum
	local isSingleInstance = inst and assetTypeEnum
	assert((nil ~= fullBodyAssets) ~= (nil ~= isSingleInstance)) -- one, but not both, should have a value

	local success, reasons, boundsResult
	if fullBodyAssets then
		success, reasons, boundsResult =
			BoundsCalculator.calculateFullBodyBounds(fullBodyAssets :: Types.AllBodyParts, validationContext)
	else
		success, reasons, boundsResult = BoundsCalculator.calculateAssetBounds(inst :: Instance, validationContext)
	end

	if not success then
		return success, reasons
	end
	local minMaxBounds = boundsResult :: Types.BoundsData

	local scaleType: string?
	success, reasons, scaleType = getScaleType(fullBodyAssets, inst, assetTypeEnum, validationContext)
	if not success then
		return success, reasons
	end

	local reasonsAccumulator = FailureReasonsAccumulator.new()

	local minSize, maxSize
	if fullBodyAssets then
		minSize = Constants.FULL_BODY_BOUNDS[scaleType :: string].minSize
		maxSize = Constants.FULL_BODY_BOUNDS[scaleType :: string].maxSize
	else
		minSize = Constants.ASSET_TYPE_INFO[assetTypeEnum].bounds[scaleType].minSize
		maxSize = Constants.ASSET_TYPE_INFO[assetTypeEnum].bounds[scaleType].maxSize
	end

	reasonsAccumulator:updateReasons(validateMinBoundsInternal(minSize, assetTypeEnum, minMaxBounds, validationContext))

	reasonsAccumulator:updateReasons(validateMaxBoundsInternal(maxSize, assetTypeEnum, minMaxBounds, validationContext))

	Analytics.recordScriptTime(script.Name, startTime, validationContext)

	return reasonsAccumulator:getFinalResults()
end

return validateAssetBounds
