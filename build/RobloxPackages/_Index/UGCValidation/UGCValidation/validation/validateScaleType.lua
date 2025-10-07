--[[
	check whether a StringValue representing an AvatarPartScaleType has one of the permitted scale types
]]

local root = script.Parent.Parent

local Constants = require(root.Constants)
local Types = require(root.util.Types)

local Analytics = require(root.Analytics)

local function validateScaleType(
	partScaleTypeNullable: StringValue?,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	if not partScaleTypeNullable then
		return true -- a missing partScaleType is ok as it is optional in some schemas
	end
	local partScaleType = partScaleTypeNullable :: StringValue

	if not Constants.AvatarPartScaleTypes[partScaleType.Value] then
		Analytics.reportFailure(
			Analytics.ErrorType.validateScaleType_InvalidAvatarPartScaleType :: string,
			nil,
			validationContext
		)
		assert(partScaleType.Parent) -- a partScaleType will never be the root, it'll have a parent
		return false,
			{
				string.format(
					"The AvatarPartScaleType value in '%s' is invalid. Please, verify the value you are using is either Classic, ProportionsSlender, or ProportionsNormal.",
					partScaleType.Parent.Name
				),
			}
	end
	return true
end

return validateScaleType
