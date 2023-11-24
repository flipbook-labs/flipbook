-- Errors from `t` interfaces look like:
--
--  [interface] bad value for storyRoots:
--
-- So the pattern we use is aimed at capturing that last `storyRoots` part.
local VARIABLE_CAPTURE_PATTERN = "[interface] .* (%w+):"

local function getLineFromTypecheckError(err: string, source: string): number?
	local variable = err:match(VARIABLE_CAPTURE_PATTERN)

	if variable then
		local lineNumber = 1

		for line in source:gmatch("[^\n]+") do
			if line:match(variable) then
				return lineNumber
			else
				lineNumber += 1
			end
		end
	end
	return nil
end

return getLineFromTypecheckError
