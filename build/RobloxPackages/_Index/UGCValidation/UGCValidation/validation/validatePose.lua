--[[
	validatePose.lua checks arms and legs to ensure they are approximately in I pose, A pose, or T pose
]]

local root = script.Parent.Parent

local AssetCalculator = require(root.util.AssetCalculator)
local canBeNormalized = require(root.util.canBeNormalized)
local prettyPrintVector3 = require(root.util.prettyPrintVector3)
local getPartNamesInHierarchyOrder = require(root.util.getPartNamesInHierarchyOrder)
local AssetTraversalUtils = require(root.util.AssetTraversalUtils)
local Types = require(root.util.Types)

local getFFlagUGCValidateStraightenLimbsPose = require(root.flags.getFFlagUGCValidateStraightenLimbsPose)

local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)

local UGCValidatePoseDegFromXYPlane = game:DefineFastInt("UGCValidatePoseDegFromXYPlane", 20)
local UGCValidatePoseArmMinDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePoseArmMinDegFromXVectorOnXYPlane", -90)
local UGCValidatePoseArmMaxDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePoseArmMaxDegFromXVectorOnXYPlane", 30)
local UGCValidatePoseLegMinDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePoseLegMinDegFromXVectorOnXYPlane", -93)
local UGCValidatePoseLegMaxDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePoseLegMaxDegFromXVectorOnXYPlane", -60)

local UGCValidatePartDegFromXYPlane = game:DefineFastInt("UGCValidatePartDegFromXYPlane", 30)
local UGCValidatePartArmMinDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePartArmMinDegFromXVectorOnXYPlane", -110)
local UGCValidatePartArmMaxDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePartArmMaxDegFromXVectorOnXYPlane", 40)
local UGCValidatePartLegMinDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePartLegMinDegFromXVectorOnXYPlane", -93)
local UGCValidatePartLegMaxDegFromXVectorOnXYPlane =
	game:DefineFastInt("UGCValidatePartLegMaxDegFromXVectorOnXYPlane", -60)

local function validateAngleFromXYPlane(
	asset: Enum.AssetType,
	inverseYVectorOnXYPlane: Vector3,
	inverseYVector: Vector3,
	partName: string?
): (boolean, { string }?)
	local reasonsAccumulator = FailureReasonsAccumulator.new()

	local angle = math.deg(math.acos(inverseYVectorOnXYPlane:Dot(inverseYVector)))
	local limit = if getFFlagUGCValidateStraightenLimbsPose() and partName
		then UGCValidatePartDegFromXYPlane
		else UGCValidatePoseDegFromXYPlane
	if angle > limit then
		reasonsAccumulator:updateReasons(false, {
			string.format(
				"%s is at a %d degree angle from the X,Y plane, it must be within %d degrees. Make sure the character is in I pose, A pose, or T pose",
				if getFFlagUGCValidateStraightenLimbsPose() and partName
					then asset.Name .. " (" .. partName .. ")"
					else asset.Name,
				angle,
				limit
			),
		})
	end
	return reasonsAccumulator:getFinalResults()
end

local function validateAngleFromWorldXVectorOnXYPlane(
	asset: Enum.AssetType,
	inverseYVectorOnXYPlane: Vector3,
	xVector: Vector3,
	minAngle: number,
	maxAngle: number,
	partName: string?
): (boolean, { string }?)
	local angle = math.deg(math.acos(inverseYVectorOnXYPlane:Dot(xVector)))
	angle = if inverseYVectorOnXYPlane.Y > 0 then angle else -angle

	local reasonsAccumulator = FailureReasonsAccumulator.new()

	if angle < minAngle or angle > maxAngle then
		reasonsAccumulator:updateReasons(false, {
			string.format(
				"%s is at a %d angle of the [%s] vector on the X,Y plane, it must be between %d and %d degrees. Make sure the character is in I pose, A pose, or T pose",
				if getFFlagUGCValidateStraightenLimbsPose() and partName
					then asset.Name .. " (" .. partName .. ")"
					else asset.Name,
				angle,
				prettyPrintVector3(xVector),
				minAngle,
				maxAngle
			),
		})
	end
	return reasonsAccumulator:getFinalResults()
end

local function validateInternal(
	singleAsset: Enum.AssetType,
	transformOpt: CFrame?,
	partName: string?
): (boolean, { string }?)
	if not transformOpt then
		return false,
			{
				string.format(
					"Failed to calculate %s asset CFrame. Make sure the character is in I pose, A pose, or T pose, and the parts are not all in the same position",
					if partName then singleAsset.Name .. " (" .. partName .. ")" else singleAsset.Name
				),
			}
	end
	local transform = transformOpt :: CFrame

	local yVectorOnXYPlane = transform.YVector.Unit - (Vector3.zAxis * (transform.YVector.Unit:Dot(Vector3.zAxis)))
	if not canBeNormalized(yVectorOnXYPlane) then
		return false,
			{
				string.format(
					"%s is pointing along the world Z vector. Make sure the character is in I pose, A pose, or T pose",
					if partName then singleAsset.Name .. " (" .. partName .. ")" else singleAsset.Name
				),
			}
	end
	local inverseYVectorOnXYPlane = -yVectorOnXYPlane.Unit
	local inverseYVector = -transform.YVector.Unit

	local reasonsAccumulator = FailureReasonsAccumulator.new()
	reasonsAccumulator:updateReasons(
		validateAngleFromXYPlane(singleAsset, inverseYVectorOnXYPlane, inverseYVector, partName)
	)

	local xVector = if singleAsset == Enum.AssetType.RightArm or singleAsset == Enum.AssetType.RightLeg
		then Vector3.xAxis
		else -Vector3.xAxis

	local minAngle, maxAngle
	if partName then
		if singleAsset == Enum.AssetType.RightArm or singleAsset == Enum.AssetType.LeftArm then
			minAngle, maxAngle =
				UGCValidatePartArmMinDegFromXVectorOnXYPlane, UGCValidatePartArmMaxDegFromXVectorOnXYPlane
		else
			minAngle, maxAngle =
				UGCValidatePartLegMinDegFromXVectorOnXYPlane, UGCValidatePartLegMaxDegFromXVectorOnXYPlane
		end
	else
		if singleAsset == Enum.AssetType.RightArm or singleAsset == Enum.AssetType.LeftArm then
			minAngle, maxAngle =
				UGCValidatePoseArmMinDegFromXVectorOnXYPlane, UGCValidatePoseArmMaxDegFromXVectorOnXYPlane
		else
			minAngle, maxAngle =
				UGCValidatePoseLegMinDegFromXVectorOnXYPlane, UGCValidatePoseLegMaxDegFromXVectorOnXYPlane
		end
	end
	reasonsAccumulator:updateReasons(
		validateAngleFromWorldXVectorOnXYPlane(
			singleAsset,
			inverseYVectorOnXYPlane,
			xVector,
			minAngle,
			maxAngle,
			partName
		)
	)
	return reasonsAccumulator:getFinalResults()
end

local function validateAssetParts(singleAsset: Enum.AssetType, inst: Instance): (boolean, { string }?)
	local allTransforms = AssetCalculator.calculateAllTransformsForAsset(singleAsset, inst)

	local reasonsAccumulator = FailureReasonsAccumulator.new()
	for _, partName in getPartNamesInHierarchyOrder(singleAsset) do
		if not AssetTraversalUtils.getAssetRigChild(singleAsset, partName) then
			continue -- the end of the hierarchy has no link to a child part in the rig, so skip the end part
		end
		local partCFrame = AssetCalculator.calculatePartCFrameFromRigAttachments(
			singleAsset,
			inst:FindFirstChild(partName) :: MeshPart,
			allTransforms[partName]
		)
		reasonsAccumulator:updateReasons(validateInternal(singleAsset, partCFrame, partName))
	end
	return reasonsAccumulator:getFinalResults()
end

local function validatePose(inst: Instance, validationContext: Types.ValidationContext): (boolean, { string }?)
	local singleAsset = validationContext.assetTypeEnum :: Enum.AssetType
	assert(singleAsset)

	if
		singleAsset ~= Enum.AssetType.LeftArm
		and singleAsset ~= Enum.AssetType.RightArm
		and singleAsset ~= Enum.AssetType.LeftLeg
		and singleAsset ~= Enum.AssetType.RightLeg
	then
		return true
	end

	local assetCFrameOpt = AssetCalculator.calculateAssetCFrame(singleAsset, inst)

	if getFFlagUGCValidateStraightenLimbsPose() then
		local reasonsAccumulator = FailureReasonsAccumulator.new()
		reasonsAccumulator:updateReasons(validateInternal(singleAsset, assetCFrameOpt))
		reasonsAccumulator:updateReasons(validateAssetParts(singleAsset, inst))
		return reasonsAccumulator:getFinalResults()
	else
		if not assetCFrameOpt then
			return false,
				{
					string.format(
						"Failed to calculate %s asset CFrame. Make sure the character is in I pose, A pose, or T pose, and the parts are not all in the same position",
						singleAsset.Name
					),
				}
		end
		local assetCFrame = assetCFrameOpt :: CFrame

		local yVectorOnXYPlane = assetCFrame.YVector.Unit
			- (Vector3.zAxis * (assetCFrame.YVector.Unit:Dot(Vector3.zAxis)))
		if not canBeNormalized(yVectorOnXYPlane) then
			return false,
				{
					string.format(
						"%s is pointing along the world Z vector. Make sure the character is in I pose, A pose, or T pose",
						singleAsset.Name
					),
				}
		end
		local inverseYVectorOnXYPlane = -yVectorOnXYPlane.Unit
		local inverseYVector = -assetCFrame.YVector.Unit

		local reasonsAccumulator = FailureReasonsAccumulator.new()
		reasonsAccumulator:updateReasons(validateAngleFromXYPlane(singleAsset, inverseYVectorOnXYPlane, inverseYVector))

		local xVector = if singleAsset == Enum.AssetType.RightArm or singleAsset == Enum.AssetType.RightLeg
			then Vector3.xAxis
			else -Vector3.xAxis

		local minAngle, maxAngle
		if singleAsset == Enum.AssetType.RightArm or singleAsset == Enum.AssetType.LeftArm then
			minAngle, maxAngle =
				UGCValidatePoseArmMinDegFromXVectorOnXYPlane, UGCValidatePoseArmMaxDegFromXVectorOnXYPlane
		else
			minAngle, maxAngle =
				UGCValidatePoseLegMinDegFromXVectorOnXYPlane, UGCValidatePoseLegMaxDegFromXVectorOnXYPlane
		end
		reasonsAccumulator:updateReasons(
			validateAngleFromWorldXVectorOnXYPlane(singleAsset, inverseYVectorOnXYPlane, xVector, minAngle, maxAngle)
		)
		return reasonsAccumulator:getFinalResults()
	end
end

return validatePose
