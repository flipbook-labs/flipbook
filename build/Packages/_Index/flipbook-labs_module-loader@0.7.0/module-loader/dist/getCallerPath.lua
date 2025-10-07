local root = script.Parent

local LOADSTRING_PATH_PATTERN = '%[string "(.*)"%]'

local function getCallerPath(): string?
	local level = 1

	while true do
		local path = debug.info(level, "s")

		if path then
			-- Skip over any path that is a descendant of this package
			if not path:find(root.Name, nil, true) then
				-- Sometimes the path is represented as `[string "path.to.module"]`
				-- so we match for the instance path and, if found, return it
				local pathFromLoadstring = path:match(LOADSTRING_PATH_PATTERN)

				if pathFromLoadstring then
					return pathFromLoadstring
				else
					return path
				end
			end
		else
			return nil
		end

		level += 1
	end
end

return getCallerPath
