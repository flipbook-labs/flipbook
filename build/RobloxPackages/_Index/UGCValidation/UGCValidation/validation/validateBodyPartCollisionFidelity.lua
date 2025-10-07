local root = script.Parent.Parent

local getEngineFeatureRemoveProxyWrap = require(root.flags.getEngineFeatureRemoveProxyWrap)

local Analytics = require(root.Analytics)

local Types = require(root.util.Types)
local checkForProxyWrap = require(root.util.checkForProxyWrap)

local FStringUGCValidationBodyPartCollisionFidelity =
	game:DefineFastString("UGCValidationBodyPartCollisionFidelity", "Default")

local function validateBodyPartCollisionFidelity(
	rootInstance: Instance,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local allowEditableInstances = validationContext.allowEditableInstances
	local instances = rootInstance:GetDescendants()
	table.insert(instances, 1, rootInstance)

	local expectedCollisionFidelity = Enum.CollisionFidelity.Default
	pcall(function()
		expectedCollisionFidelity = Enum.CollisionFidelity[FStringUGCValidationBodyPartCollisionFidelity]
	end)

	local failures = {}

	for _, instance in instances do
		if not getEngineFeatureRemoveProxyWrap() then
			if allowEditableInstances and checkForProxyWrap(instance) then
				continue
			end
		end
		if instance:IsA("MeshPart") and instance.CollisionFidelity ~= expectedCollisionFidelity then
			table.insert(
				failures,
				`Expected {instance:GetFullName()}.CollisionFidelity to be {expectedCollisionFidelity.Name}`
			)
		end
	end

	if #failures == 0 then
		return true
	else
		Analytics.reportFailure(Analytics.ErrorType.validateBodyPartCollisionFidelity, nil, validationContext)
		return false, failures
	end
end

return validateBodyPartCollisionFidelity
