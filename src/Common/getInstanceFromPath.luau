--[[
	Gets an instance based off the result of `getInstancePath`.

	The reason we don't use GetFullName is because it uses a dot (.) as the path
	separator which makes it difficult to disambiguate stories and test files
	(Foo.story and Foo.spec, respectively)

	Returns `nil` if the instance is outside the DataModel or otherwise cannot
	be found.
]]

local tryGetService = require("@root/RobloxInternal/tryGetService")

local PATH_SEPERATOR = "/"

local function getInstanceFromPath(path: string): Instance?
	local parts = path:split(PATH_SEPERATOR)
	local serviceName = parts[1]

	if serviceName then
		-- This function only works for instances in the DataModel. As such, the
		-- first part of the path will always be a service, so if we can't find
		-- one we exit out and return nil
		local current = tryGetService(serviceName)

		if current then
			for i = 2, #parts do
				local found = current:FindFirstChild(parts[i])

				if found then
					current = found
				else
					return nil
				end
			end

			return current
		end
	end

	return nil
end

return getInstanceFromPath
