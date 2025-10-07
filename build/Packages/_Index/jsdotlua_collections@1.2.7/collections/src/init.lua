local Array = require(script:WaitForChild('Array'))
local Map = require(script:WaitForChild('Map'))
local Object = require(script:WaitForChild('Object'))
local Set = require(script:WaitForChild('Set'))
local WeakMap = require(script:WaitForChild('WeakMap'))
local inspect = require(script:WaitForChild('inspect'))

local types = require(script.Parent:WaitForChild('es7-types'))

export type Array<T> = types.Array<T>
export type Map<T, V> = types.Map<T, V>
export type Object = types.Object
export type Set<T> = types.Set<T>
export type WeakMap<T, V> = types.WeakMap<T, V>

return {
	Array = Array,
	Object = Object,
	Map = Map.Map,
	coerceToMap = Map.coerceToMap,
	coerceToTable = Map.coerceToTable,
	Set = Set,
	WeakMap = WeakMap,
	inspect = inspect,
}
