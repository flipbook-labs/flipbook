local __DEV__ = _G.__DEV__
local isArray = require(script.Parent:WaitForChild('isArray'))
local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))
type Array<T> = types.Array<T>

return function<T>(array: Array<T>, ...: T): number
	if __DEV__ then
		if not isArray(array) then
			error(string.format("Array.unshift called on non-array %s", typeof(array)))
		end
	end

	local numberOfItems = select("#", ...)
	if numberOfItems > 0 then
		for i = numberOfItems, 1, -1 do
			local toInsert = select(i, ...)
			table.insert(array, 1, toInsert)
		end
	end

	return #array
end
