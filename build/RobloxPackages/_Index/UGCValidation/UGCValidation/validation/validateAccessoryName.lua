local root = script.Parent.Parent

local Analytics = require(root.Analytics)
local Types = require(root.util.Types)

local function validateAccessoryName(accessory: Instance, validationContext: Types.ValidationContext)
	if string.match(accessory.Name, "Accessory %(.+%)$") then
		return true
	else
		Analytics.reportFailure(Analytics.ErrorType.validateAccessoryName, nil, validationContext)
		return false, { 'Accessory.Name must match pattern "Accessory (Name)"' }
	end
end

return validateAccessoryName
