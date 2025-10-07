--!strict
local T = require(script.Parent.Parent.Types)

local toSet = require(script.Parent.toSet)
local toArray = require(script.Parent.Parent.Set.toArray)
local setDifference = require(script.Parent.Parent.Set.difference)

--[=[
  @function difference
  @within Array

  @param array Array<V> -- The array to compare.
  @param ... ...Array<V> -- The arrays to compare against.
  @return Array<V> -- The difference between the arrays.

  Returns an array of values that are in the first array, but not in the other arrays.

  ```lua
  local array1 = { "hello", "world" }
  local array2 = { "cat", "dog", "hello" }

  local difference = Difference(array1, array2) -- { "world" }
  ```
]=]
local function difference<V>(array: T.Array<V>, ...: T.Array<V>): T.Array<V>
	local arraySet = toSet(array)
	local otherSets = {}

	for _, nextArray in { ... } do
		if typeof(nextArray) ~= "table" then
			continue
		end

		table.insert(otherSets, toSet(nextArray))
	end

	local differenceSet = setDifference(arraySet, unpack(otherSets))

	return toArray(differenceSet)
end

return difference
