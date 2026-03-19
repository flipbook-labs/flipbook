local fs = require("@std/fs")
local json = require("@std/json")

local project = require("@repo/project")
local types = require("@scripts/lib/build-system/types")

local function writeBuildCacheAsync(buildCache: types.BuildCache)
	local contents = json.serialize(buildCache :: json.object, true)
	fs.writestringtofile(project.BUILD_CACHE_PATH, contents)
end

return writeBuildCacheAsync
