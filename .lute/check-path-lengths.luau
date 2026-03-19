local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local cli = require("@luaupkg/batteries/cli")
local path = require("@std/path")

local findWhere = FlipbookBatteries.findWhere

-- This is the maximum path length on Windows. There are ways to enable longer
-- file paths in Windows, but many programs fall apart when hitting this limit
-- regardless. As such, we're bound by this number. Nothing we can do about it.
local MAX_PATH = 260

-- This number is derived from the path that Flipbook gets extracted to in
-- Roblox's internal CI. This is another one of those "nothing we can do about
-- it" numbers.
local PREFIX_LENGTH = 97

-- Finally, our own max path length is just the difference between the Windows
-- max path and the reserved prefix in Flipbook's path. We just have to make
-- sure our file paths are within the limit, which really is not hard, and in
-- practice is unlikely to happen again, but just in case it does we include all
-- of this as an extra measure to ensure downstream dependents can keep chugging
-- along
local MAX_ALLOWED = MAX_PATH - PREFIX_LENGTH

local args = cli.parser()

args:add("artifact", "option", {
	help = "Path to the artifact root to check",
	aliases = { "a" },
})

args:parse({ ... })

local artifactRoot =
	assert(args:get("artifact"), "Please supply the --artifact flag with a path to one of the build artifacts.")

artifactRoot = path.normalize(artifactRoot)

local longPaths = findWhere(artifactRoot, function(filePath)
	local relativePath = tostring(filePath):sub(#tostring(artifactRoot) + 1)
	return #relativePath > MAX_ALLOWED
end)

for _, longPath in longPaths do
	local relativePath = path.relative(artifactRoot, longPath)
	print(`({#tostring(relativePath)}) {relativePath}`)
end
