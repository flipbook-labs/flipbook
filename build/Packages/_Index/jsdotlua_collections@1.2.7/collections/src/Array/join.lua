local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))
type Array<T> = types.Array<T>
local map = require(script.Parent:WaitForChild('map'))

return function<T>(arr: Array<T>, separator: string?): string
	if #arr == 0 then
		return ""
	end
	-- JS does tostring conversion implicitely but in Lua we need to do that explicitely
	local stringifiedArray = map(arr, function(item)
		return tostring(item)
	end)

	return table.concat(stringifiedArray, separator or ",")
end
