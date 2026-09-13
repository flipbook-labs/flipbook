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

return asTable
