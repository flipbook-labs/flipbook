--!strict

--[=[
  @function withKeys
  @within Dictionary

  @param dictionary {[K]: V} -- The dictionary to select the keys from.
  @param keys ...K -- The keys to keep.
  @return {[K]: V} -- The dictionary with only the given keys.

  Returns a dictionary with the given keys.

  ```lua
  local dictionary = { hello = "world", cat = "meow", dog = "woof", unicorn = "rainbow" }

  local withoutCatDog = WithKeys(dictionary, "cat", "dog") -- { cat = "meow", dog = "woof" }
  ```
]=]
local function withKeys<K, V>(dictionary: { [K]: V }, ...: K): { [K]: V }
	local result = {}

	for _, key in ipairs({ ... }) do
		result[key] = dictionary[key]
	end

	return result
end

return withKeys
