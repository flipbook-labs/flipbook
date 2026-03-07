local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local path = require("@std/path")
local process = require("@std/process")

local project = require("@repo/project")

local run = FlipbookBatteries.run
local findWhere = FlipbookBatteries.findWhere

local function pathsToString(paths: { path.pathlike }): { string }
	local new = {}
	for _, filePath in paths do
		table.insert(new, tostring(filePath))
	end
	return new
end

local function findLuaFiles()
	local result = {}

	for _, folder in project.FOLDERS_TO_LINT do
		local matches = findWhere(folder, function(filePath)
			return path.extname(filePath) == ".lua"
		end)

		for _, match in matches do
			table.insert(result, match)
		end
	end

	return result
end

local pathsToLint = pathsToString({ table.unpack(project.FOLDERS_TO_LINT) })

run("selene", { table.unpack(pathsToLint) })

run("stylua", {
	"--check",
	table.unpack(pathsToLint),
})

local files = findLuaFiles()
if #files > 0 then
	print("[err] the following file(s) are using the '.lua' extension. Please change to '.luau' and try again")
	print(`{table.concat(files, "\n")}`)
	process.exit(1)
end
