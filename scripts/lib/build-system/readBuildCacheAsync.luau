local fs = require("@lute/fs")
local json = require("@std/json")

local project = require("@repo/project")
local types = require("@scripts/lib/build-system/types")

local function readBuildCacheAsync(): types.BuildCache
	if fs.exists(project.BUILD_CACHE_PATH) then
		local handle = fs.open(project.BUILD_CACHE_PATH)
		local content = fs.read(handle)
		fs.close(handle)
		return json.deserialize(content) :: any
	else
		return {
			hashes = {},
		}
	end
end

return readBuildCacheAsync
