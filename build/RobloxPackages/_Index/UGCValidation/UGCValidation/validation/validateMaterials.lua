local root = script.Parent.Parent

local Types = require(root.util.Types)

local Analytics = require(root.Analytics)
local Constants = require(root.Constants)

-- ensures no descendant of instance has a material that does not exist in Constants.MATERIAL_WHITELIST
local function validateMaterials(instance: Instance, validationContext: Types.ValidationContext): (boolean, { string }?)
	local materialFailures = {}

	local objects: { Instance } = instance:GetDescendants()
	table.insert(objects, instance)
	for _, descendant in objects do
		if descendant:IsA("BasePart") and not Constants.MATERIAL_WHITELIST[descendant.Material] then
			table.insert(materialFailures, descendant:GetFullName())
		end
	end

	if #materialFailures > 0 then
		local reasons = {}
		local acceptedMaterialNames = {}
		for material in pairs(Constants.MATERIAL_WHITELIST) do
			table.insert(acceptedMaterialNames, material.Name)
		end
		table.insert(reasons, "Invalid material setup for")
		for _, name in pairs(materialFailures) do
			table.insert(reasons, name)
		end
		table.insert(reasons, "Accepted values are: " .. table.concat(acceptedMaterialNames, ", "))
		Analytics.reportFailure(Analytics.ErrorType.validateMaterials, nil, validationContext)
		return false, reasons
	end

	return true
end

return validateMaterials
