--!strict
local T = require(script.Parent.Parent.Types)

--[=[
  @function difference
  @within Set

  @param set Set<V> -- The set to compare.
  @param ... ...Set<V> -- The sets to compare against.
  @return Set<V> -- The difference between the sets.

  Returns a set of values that are in the first set, but not in the other sets.

  ```lua
  local set1 = { hello = true, world = true }
  local set2 = { cat = true, dog = true, hello = true }

  local difference = Difference(set1, set2) -- { world = true }
  ```
]=]
local function difference<V>(set: T.Set<V>, ...: T.Set<V>): T.Set<V>
	local diff = table.clone(set)

	for _, nextSet in { ... } do
		if typeof(nextSet) ~= "table" then
			continue
		end

		for value in nextSet do
			diff[value] = nil
		end
	end

	return diff
end

return difference
