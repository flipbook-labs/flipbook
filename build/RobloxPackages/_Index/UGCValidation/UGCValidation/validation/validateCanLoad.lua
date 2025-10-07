local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Analytics = require(root.Analytics)

local Types = require(root.util.Types)

local function validateCanLoad(assetId: string, validationContext: Types.ValidationContext): (boolean, { string }?)
	local success, result = pcall(function()
		return UGCValidationService:CanLoadAsset(assetId)
	end)

	if not success or not result then
		Analytics.reportFailure(Analytics.ErrorType.validateCanLoad, nil, validationContext)
		return false, { "Asset could not be loaded" }
	end

	return true
end

return validateCanLoad
