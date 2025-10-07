--!strict
local T = require(script.Parent.Parent.Types)

local toSet = require(script.Parent.toSet)
local toArray = require(script.Parent.Parent.Set.toArray)
local setDifferenceSymmetric = require(script.Parent.Parent.Set.differenceSymmetric)

--[=[
  @function differenceSymmetric
  @within Array

  @param array Array<V> -- The array to compare.
  @param ... ...Array<V> -- The arrays to compare against.
  @return Array<V> -- The symmetric difference between the arrays.

  Returns an array of values that are in the first array, but not in the other arrays, and vice versa.

  ```lua
  local array1 = { "hello", "world" }
  local array2 = { "cat", "dog", "hello" }

  local difference = DifferenceSymmetric(array1, array2) -- { "world", "cat", "dog" }
  ```
]=]
local function differenceSymmetric<V>(array: T.Array<V>, ...: T.Array<V>): T.Array<V>
	local arraySet = toSet(array)
	local otherSets = {}

	for _, nextArray in { ... } do
		if typeof(nextArray) ~= "table" then
			continue
		end

		table.insert(otherSets, toSet(nextArray))
	end

	local differenceSet = setDifferenceSymmetric(arraySet, unpack(otherSets))

	return toArray(differenceSet)
end

return differenceSymmetric
