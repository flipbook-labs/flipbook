local function getOptionalString(params: { [string]: unknown }, key: string): string?
	local value = params[key]
	if value == nil then
		return nil
	end
	if type(value) ~= "string" or value == "" then
		error(`{key} must be a non-empty string when provided`)
	end
	return value
end

return getOptionalString
