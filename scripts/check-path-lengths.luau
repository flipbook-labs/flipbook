local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local cli = require("@luaupkg/batteries/cli")
local path = require("@std/path")
local process = require("@std/process")

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

local artifactRoot = path.normalize(args:get("artifact"))

local longPaths = findWhere(artifactRoot, function(filePath)
	local relativePath = tostring(filePath):sub(#tostring(artifactRoot) + 1)
	return #relativePath > MAX_ALLOWED
end)

if #longPaths > 0 then
	print(`[err] the following paths exceed the {MAX_ALLOWED} character limit:`)
	for _, longPath in longPaths do
		local relativePath = path.relative(artifactRoot, longPath)
		print(`  ({#tostring(relativePath)}) {relativePath}`)
	end
	process.exit(1)
end

print(`all paths are within the {MAX_ALLOWED} character limit`)
