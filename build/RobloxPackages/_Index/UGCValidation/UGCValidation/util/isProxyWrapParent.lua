-- If an asset was created in In-Experience Creation, then if it has a WrapTarget, it will have a child called ProxyMeshPart. This
-- proxy part holds the cage mesh data representing the user's edits from IEC. This is the cage data we want to validate, rather
-- then the data associated with CageMeshId
-- TODO: remove this file once getEngineFeatureRemoveProxyWrap is removed

local root = script.Parent.Parent
local Constants = require(root.Constants)

return function(instance: Instance): boolean
	if not instance or not instance:IsA("WrapTarget") then
		return false
	end

	for _, child in instance:GetChildren() do
		if child:IsA("MeshPart") and child:GetAttribute(Constants.ProxyWrapAttributeName) then
			return true
		end
	end

	return false
end
