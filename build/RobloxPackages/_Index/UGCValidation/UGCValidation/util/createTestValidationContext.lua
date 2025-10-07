local root = script.Parent.Parent

local UGCValidationService = game:GetService("UGCValidationService")

local Types = require(root.util.Types)

return function(assetType: Enum.AssetType?, instance: { Instance }): Types.ValidationContext
	local validationContext = {
		isServer = true,
		assetTypeEnum = assetType,
		validateMeshPartAccessories = false,
	}

	local editableMeshes = {}
	local editableImages = {}
	for _, inst in instance do
		for _, desc in inst:GetDescendants() do
			if desc:IsA("BinaryStringValue") then
				if desc.Name == "MeshId" or desc.Name == "CageMeshId" or desc.Name == "ReferenceMeshId" then
					if not editableMeshes[desc.Parent] then
						editableMeshes[desc.Parent] = {}
					end
					editableMeshes[desc.Parent][desc.Name] = {
						created = true,
						instance = UGCValidationService:CreateEditableMeshFromBinaryStringRobloxOnly(desc),
					}
				else
					if not editableImages[desc.Parent] then
						editableImages[desc.Parent] = {}
					end
					editableImages[desc.Parent][desc.Name] = {
						created = true,
						instance = UGCValidationService:CreateEditableImageFromBinaryStringRobloxOnly(desc),
					}
				end
			end
		end
	end

	validationContext.editableMeshes = editableMeshes :: Types.EditableMeshes
	validationContext.editableImages = editableImages :: Types.EditableImages

	return validationContext
end
