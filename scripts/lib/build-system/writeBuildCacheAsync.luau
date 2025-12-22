local fs = require("@lute/fs")
local json = require("@std/json")

local project = require("@repo/project")
local types = require("@scripts/lib/build-system/types")

local function writeBuildCacheAsync(buildCache: types.BuildCache)
	fs.writestringtofile(project.BUILD_CACHE_PATH, json.serialize(buildCache, true))
end

return writeBuildCacheAsync
