local root = script.Parent

local Constants = require(root.Constants)

local ConstantsInterface = {}

function ConstantsInterface.isBodyPart(assetTypeEnum: Enum.AssetType): boolean
	return Constants.ASSET_TYPE_INFO[assetTypeEnum] and Constants.ASSET_TYPE_INFO[assetTypeEnum].isBodyPart
end

function ConstantsInterface.getBodyPartAssets(): { Enum.AssetType }
	local results = {}
	for assetTypeEnum, assetInfo in Constants.ASSET_TYPE_INFO do
		if not assetInfo.isBodyPart then
			continue
		end
		table.insert(results, assetTypeEnum)
	end
	return results
end

function ConstantsInterface.getRigAttachmentToParent(assetTypeEnum: Enum.AssetType?, partName: string): string
	if not assetTypeEnum then
		assetTypeEnum = Constants.UGC_BODY_PART_NAMES_TO_ASSET_TYPE[partName]
	end

	if assetTypeEnum then
		local assetInfo = Constants.ASSET_TYPE_INFO[assetTypeEnum :: Enum.AssetType]
		if not assetInfo.isBodyPart then
			return ""
		end
		return assetInfo.subParts[partName].rigAttachmentToParent.name
	end
	return ""
end

function ConstantsInterface.getAttachments(assetTypeEnum: Enum.AssetType?, partName: string): { string }
	if not assetTypeEnum then
		assetTypeEnum = Constants.UGC_BODY_PART_NAMES_TO_ASSET_TYPE[partName]
	end

	local validationData = nil
	if assetTypeEnum then
		local assetInfo = Constants.ASSET_TYPE_INFO[assetTypeEnum :: Enum.AssetType]
		if not assetInfo.isBodyPart then
			return {}
		end
		validationData = assetInfo.subParts[partName]
	end
	local results = {}
	if validationData then
		table.insert(results, validationData.rigAttachmentToParent.name)

		for attachmentName in validationData.otherAttachments do
			table.insert(results, attachmentName)
		end
	end
	return results
end

return ConstantsInterface
