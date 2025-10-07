local ES7Types = require(script.Parent.Parent:WaitForChild('es7-types'))

local Map = require(script:WaitForChild('Map'))
local coerceToMap = require(script:WaitForChild('coerceToMap'))
local coerceToTable = require(script:WaitForChild('coerceToTable'))

export type Map<K, V> = ES7Types.Map<K, V>

return {
	Map = Map,
	coerceToMap = coerceToMap,
	coerceToTable = coerceToTable,
}
