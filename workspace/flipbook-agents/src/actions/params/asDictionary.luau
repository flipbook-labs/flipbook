local function asDictionary(value: unknown?): { [string]: unknown }
	if type(value) ~= "table" then
		return {}
	end
	for key in value :: { [unknown]: unknown } do
		if type(key) ~= "string" then
			error("dictionary keys must be strings")
		end
	end
	return value :: { [string]: unknown }
end

return asDictionary
