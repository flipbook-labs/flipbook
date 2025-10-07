-- upstream: https://github.com/Roblox/jest-roblox/blob/408eac1b8d210e6e07387fb341fa9b9e181de897/src/roblox-shared/src/cleanLoadStringStack.lua

return function(line: string): string
	local spacing, filePath, lineNumber, extra = line:match('(%s*)%[string "(.-)"%]:(%d+)(.*)')
	if filePath then
		local match = filePath
		if spacing then
			match = spacing .. match
		end
		if lineNumber then
			match = match .. ":" .. lineNumber
		end
		if extra then
			match = match .. extra
		end
		return match
	end
	return line
end
