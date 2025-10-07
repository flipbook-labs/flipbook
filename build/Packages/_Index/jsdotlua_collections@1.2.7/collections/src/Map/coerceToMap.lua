local Map = require(script.Parent:WaitForChild('Map'))
local Object = require(script.Parent.Parent:WaitForChild('Object'))
local instanceOf = require(script.Parent.Parent.Parent:WaitForChild('instance-of'))
local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))

type Map<K, V> = types.Map<K, V>
type Table<K, V> = types.Table<K, V>

local function coerceToMap(mapLike: Map<any, any> | Table<any, any>): Map<any, any>
	return instanceOf(mapLike, Map) and mapLike :: Map<any, any> -- ROBLOX: order is preserved
		or Map.new(Object.entries(mapLike)) -- ROBLOX: order is not preserved
end

return coerceToMap
