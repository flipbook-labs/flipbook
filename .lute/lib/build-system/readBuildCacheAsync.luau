local fs = require("@std/fs")
local json = require("@std/json")

local project = require("@repo/project")
local types = require("@scripts/lib/build-system/types")

local function readBuildCacheAsync(): types.BuildCache
	if fs.exists(project.BUILD_CACHE_PATH) then
		local content = fs.readFileToString(project.BUILD_CACHE_PATH)

		if content and content ~= "" then
			return json.deserialize(content) :: any
		end
	end

	return {}
end

return readBuildCacheAsync
