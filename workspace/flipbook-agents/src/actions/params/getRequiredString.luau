local function getRequiredString(params: { [string]: unknown }, key: string): string
	local value = params[key]
	if type(value) ~= "string" or value == "" then
		error(`{key} must be a non-empty string`)
	end
	return value
end

return getRequiredString
