local function asTable(params: unknown?): { [string]: unknown }
	if type(params) ~= "table" then
		return {}
	end
	for key in params :: { [unknown]: unknown } do
		if type(key) ~= "string" then
			error("params must use string keys")
		end
	end
	return params :: { [string]: unknown }
end

local function getRequiredString(params: { [string]: unknown }, key: string): string
	local value = params[key]
	if type(value) ~= "string" or value == "" then
		error(`{key} must be a non-empty string`)
	end
	return value
end

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

return {
	asTable = asTable,
	getRequiredString = getRequiredString,
	getOptionalString = getOptionalString,
	getOptionalBoolean = getOptionalBoolean,
}
