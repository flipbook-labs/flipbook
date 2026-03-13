local FlipbookBatteries = require("@luaupkg/flipbook-batteries")
local path = require("@std/path")
local process = require("@std/process")

local project = require("@repo/project")

local run = FlipbookBatteries.run
local findWhere = FlipbookBatteries.findWhere

local function valuesToString<T>(arr: { T }): { string }
	local mapped = {}
	for _, element in arr do
		table.insert(mapped, tostring(element))
	end
	return mapped
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

local pathsToLint = valuesToString(project.FOLDERS_TO_LINT)

run("selene", pathsToLint)

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
