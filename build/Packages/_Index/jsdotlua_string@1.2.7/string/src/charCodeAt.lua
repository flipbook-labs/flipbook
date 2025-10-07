local Number = require(script.Parent.Parent:WaitForChild('number'))

local NaN = Number.NaN

-- js  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/charCodeAt
-- lua http://www.lua.org/manual/5.4/manual.html#pdf-utf8.codepoint
return function(str: string, index: number): number
	if type(index) ~= "number" then
		index = 1
	end
	--[[
		Initial bounds check. Checking string.len is not an exhaustive upper bound,
		but it is cheaper to check string.len and handle utf8.offset than to check
		utf.len, which iterates over all codepoints.
	]]
	local length = string.len(str)
	if index < 1 or index > length then
		return NaN
	end

	-- utf8.offset returns nil for out of bounds
	local offset = utf8.offset(str, index)

	-- check that offset is not greater than the length of the string
	if offset == nil or offset > length then
		return NaN
	end

	local value = utf8.codepoint(str, offset, offset)

	if value == nil then
		return NaN
	end

	return value
end
