local Set = require(script.Parent.Parent:WaitForChild('Set'))
local Map = require(script.Parent.Parent:WaitForChild('Map'):WaitForChild('Map'))
local isArray = require(script.Parent:WaitForChild('isArray'))
local instanceof = require(script.Parent.Parent.Parent:WaitForChild('instance-of'))
local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))

local fromString = require(script:WaitForChild('fromString'))
local fromSet = require(script:WaitForChild('fromSet'))
local fromMap = require(script:WaitForChild('fromMap'))
local fromArray = require(script:WaitForChild('fromArray'))

type Array<T> = types.Array<T>
type Object = types.Object
type Set<T> = types.Set<T>
type Map<K, V> = types.Map<K, V>
type mapFn<T, U> = (element: T, index: number) -> U
type mapFnWithThisArg<T, U> = (thisArg: any, element: T, index: number) -> U

return function<T, U>(
	value: string | Array<T> | Set<T> | Map<any, any>,
	mapFn: (mapFn<T, U> | mapFnWithThisArg<T, U>)?,
	thisArg: Object?
	-- FIXME Luau: need overloading so the return type on this is more sane and doesn't require manual casts
): Array<U> | Array<T> | Array<string>
	if value == nil then
		error("cannot create array from a nil value")
	end
	local valueType = typeof(value)

	local array: Array<U> | Array<T> | Array<string>

	if valueType == "table" and isArray(value) then
		array = fromArray(value :: Array<T>, mapFn, thisArg)
	elseif instanceof(value, Set) then
		array = fromSet(value :: Set<T>, mapFn, thisArg)
	elseif instanceof(value, Map) then
		array = fromMap(value :: Map<any, any>, mapFn, thisArg)
	elseif valueType == "string" then
		array = fromString(value :: string, mapFn, thisArg)
	else
		array = {}
	end

	return array
end
