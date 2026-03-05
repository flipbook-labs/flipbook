local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local cli = require("@luaupkg/batteries/cli")
local path = require("@std/path")

local findWhere = FlipbookBatteries.findWhere

local MAX_PATH = 260
local PREFIX_LENGTH = 97
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
