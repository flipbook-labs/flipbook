--!strict
--[=[
  @function is
  @within Array

  @param object any -- The object to check.
  @return boolean -- Whether the object is an array.

  Checks if the given object is an array.

  ```lua
  local array = { 1, 2, 3 }
  local dictionary = { hello = "world" }
  local mixed = { 1, 2, hello = "world" }

  Array.is(array) -- true
  Array.is(dictionary) -- false
  Array.is(mixed) -- false
  ```
]=]
local function is(object: any): boolean
	return typeof(object) == "table" and #object > 0 and next(object, #object) == nil
end

return is
