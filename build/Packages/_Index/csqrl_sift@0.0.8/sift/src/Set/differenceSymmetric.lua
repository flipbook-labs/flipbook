--!strict
local T = require(script.Parent.Parent.Types)

--[=[
  @function differenceSymmetric
  @within Set

  @param set Set<V> -- The set to compare.
  @param ... ...Set<V> -- The sets to compare against.
  @return Set<V> -- The symmetric difference between the sets.

  Returns a set of values that are in the first set, but not in the other sets, and vice versa.

  ```lua
  local set1 = { hello = true, world = true }
  local set2 = { cat = true, dog = true, hello = true }

  local differenceSymmetric = DifferenceSymmetric(set1, set2) -- { world = true, cat = true, dog = true }
  ```
]=]
local function differenceSymmetric<V>(set: T.Set<V>, ...: T.Set<V>): T.Set<V>
	local diff = table.clone(set)

	for _, nextSet in { ... } do
		if typeof(nextSet) ~= "table" then
			continue
		end

		for value in nextSet do
			diff[value] = if diff[value] == nil then true else false
		end
	end

	for value, keep in diff do
		diff[value] = if keep then true else nil
	end

	return diff
end

return differenceSymmetric
