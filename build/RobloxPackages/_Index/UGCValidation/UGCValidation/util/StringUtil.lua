--[[
	StringUtil.lua exposes utility functions for string manipulation
]]

local StringUtil = {}

function StringUtil.keysToString(keys: { [any]: any }, sep: string, doSort: boolean?): string
	local keyStrings = {}
	for key in keys do
		table.insert(keyStrings, tostring(key))
	end

	if doSort then
		table.sort(keyStrings)
	end
	return table.concat(keyStrings, sep)
end

return StringUtil
