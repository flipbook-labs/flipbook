--[[
	Gets an instance based off the result of GetFullName().

	This is used in conjunction with debug.info() to locate the calling script.

	Returns nil if the instance is outside the DataModel.
]]

local Sift = require("@pkg/Sift")

local tryGetService = require("@root/Permissions/tryGetService")

local PATH_SEPERATOR = "."

local function getInstanceFromFullName(fullName: string): Instance?
	local parts = fullName:split(PATH_SEPERATOR)
	local serviceName = table.remove(parts, 1)

	if serviceName then
		-- This function only works for instances in the DataModel. As such, the
		-- first part of the path will always be a service, so if we can't find
		-- one we exit out and return nil
		local current = tryGetService(serviceName)

		if current then
			while #parts > 0 do
				-- Keep around a copy of the `parts` array. We are going to concat this
				-- into new paths, and incrementally remove from the right to narrow
				-- down the file path.
				local tempParts = Sift.Array.copy(parts)

				-- The result of GetFullName() uses dots to separate paths, but we also
				-- use dots in our file names (e.g. with spec and story files). As such,
				-- this block will look ahead to see if multiple parts are actually a
				-- single filename.
				for _ = 1, #tempParts do
					local name = table.concat(tempParts, PATH_SEPERATOR)
					local found = current:FindFirstChild(name)

					if found then
						current = found
						parts = Sift.List.shift(parts, #name:split(PATH_SEPERATOR))
						break
					else
						if #tempParts == 1 then
							-- This fixes a crash when searching for paths that
							-- no longer exist
							return nil
						else
							-- Reduce from the right until we find the next instance
							tempParts = Sift.List.pop(tempParts)
						end
					end
				end
			end

			return current
		end
	end

	return nil
end

return getInstanceFromFullName
