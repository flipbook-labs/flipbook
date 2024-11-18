local FLAG_PATTERN = "%-%-(%w+)"
local FLAG_ALL_IN_ONE_PATTERN = `{FLAG_PATTERN}=(%w+)`

local function parseArgs(args: { string })
	local parsedArgs: { [string]: string | boolean | number } = {}

	local skipNextToken = false

	for index, token in args do
		-- When `--foo bar` is used, these are both individual tokens that we
		-- process at the same time. In those cases, we need to skip the next
		-- token (`bar`) since it has already been picked up as a flag value
		if skipNextToken then
			skipNextToken = false
			continue
		end

		-- handle `--foo=bar` pattern
		local flagName, flagValue = token:match(FLAG_ALL_IN_ONE_PATTERN)
		if flagName and flagValue then
			parsedArgs[flagName] = flagValue
			continue
		end

		flagName = token:match(FLAG_PATTERN)
		if flagName then
			local nextToken = args[index + 1]

			if nextToken then
				-- When processing `--foo` in `--foo --bar` treat it like a boolean
				if nextToken:match(FLAG_PATTERN) then
					parsedArgs[flagName] = true
				else
					parsedArgs[flagName] = nextToken
					skipNextToken = true
				end
			else
				parsedArgs[flagName] = true
			end
		else
			error(`something went wrong: {token}`)
		end
	end

	return parsedArgs
end

return parseArgs
