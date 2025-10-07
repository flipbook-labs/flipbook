local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))
type Array<T> = types.Array<T>
type PredicateFunction<T> = (value: T, index: number, array: Array<T>) -> boolean

return function<T>(array: Array<T>, predicate: PredicateFunction<T>): T | nil
	for i = 1, #array do
		local element = array[i]
		if predicate(element, i, array) then
			return element
		end
	end
	return nil
end
