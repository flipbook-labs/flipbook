local __DEV__ = _G.__DEV__

local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))
type Array<T> = types.Array<T>
type Object = types.Object

return function(t: Object | Array<any>): boolean
	if __DEV__ then
		print("Luau now has a direct table.isfrozen call that can save the overhead of this library function call")
	end
	return table.isfrozen(t)
end
