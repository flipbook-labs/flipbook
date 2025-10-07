local __DEV__ = _G.__DEV__
local flat = require(script.Parent:WaitForChild('flat'))
local map = require(script.Parent:WaitForChild('map'))
local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))
type Array<T> = types.Array<T>
type callbackFn<T, U> = (element: T, index: number, array: Array<T>) -> U
type callbackFnWithThisArg<T, U, V> = (thisArg: V, element: T, index: number, array: Array<T>) -> U

local function flatMap<T, U, V>(
	array: Array<T>,
	callback: callbackFn<T, U> | callbackFnWithThisArg<T, U, V>,
	thisArg: V?
): Array<U>
	if __DEV__ then
		if typeof(array) ~= "table" then
			error(string.format("Array.flatMap called on %s", typeof(array)))
		end
		if typeof(callback) ~= "function" then
			error("callback is not a function")
		end
	end
	return flat(map(array, callback, thisArg))
end

return flatMap
