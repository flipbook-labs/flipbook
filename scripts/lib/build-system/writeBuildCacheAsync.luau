local fs = require("@lute/fs")
local json = require("@std/json")

local project = require("@repo/project")
local types = require("@scripts/lib/build-system/types")

local function writeBuildCacheAsync(buildCache: types.BuildCache)
	local content = json.serialize(buildCache :: json.object, true)
	local handle = fs.open(project.BUILD_CACHE_PATH, "w+")
	fs.write(handle, content)
	fs.close(handle)
end

return writeBuildCacheAsync
