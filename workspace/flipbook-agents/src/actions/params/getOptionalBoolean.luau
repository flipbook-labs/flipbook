local function getOptionalBoolean(params: { [string]: unknown }, key: string): boolean?
	local value = params[key]
	if value == nil then
		return nil
	end
	if type(value) ~= "boolean" then
		error(`{key} must be a boolean when provided`)
	end
	return value
end

return getOptionalBoolean
