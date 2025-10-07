-- https://programming-idioms.org/idiom/19/reverse-a-list/1314/lua
local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))
type Array<T> = types.Array<T>

return function<T>(t: Array<T>): Array<T>
	local n = #t
	local i = 1
	while i < n do
		t[i], t[n] = t[n], t[i]
		i = i + 1
		n = n - 1
	end
	return t
end
