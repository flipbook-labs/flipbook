-- Errors from `t` interfaces look like:
--
--  [interface] bad value for foo:
--
--  [interface] unexpected field "foo"
--
-- So the pattern we use is aimed at capturing `foo`.
local VARIABLE_CAPTURE_PATTERN_KEY = '%[interface%] unexpected field "(%w+)"'
local VARIABLE_CAPTURE_PATTERN_VALUE = "%[interface%] bad value for (%w+):"

local function getLineFromTypecheckError(err: string, source: string): number?
	local variable: string?
	for _, pattern in { VARIABLE_CAPTURE_PATTERN_KEY, VARIABLE_CAPTURE_PATTERN_VALUE } do
		variable = err:match(pattern)

		if variable then
			break
		end
	end

	if variable then
		for index, line in source:split("\n") do
			if line:match(variable) then
				return index
			end
		end
	end
	return nil
end

return getLineFromTypecheckError
