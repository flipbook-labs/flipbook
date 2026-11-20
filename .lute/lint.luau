local CodeQuality = require("@lpm/code-quality@v0.5.0")
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local path = require("@std/path")
local process = require("@std/process")

local project = require("@repo/project")

local run = FlipbookBatteries.run
local findWhere = FlipbookBatteries.findWhere

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

run("selene", { table.unpack(project.FOLDERS_TO_LINT) })

run("stylua", {
	"--check",
	table.unpack(project.FOLDERS_TO_LINT),
})

-- CodeQuality is the org's shared package of Luau lint rules, which `lute lint`
-- runs alongside its own. Lute's parallel linting can crash at random
-- (flipbook-labs/code-quality#27), so files are linted one at a time.
run("lute", {
	"lint",
	"--sequential",
	"--rules",
	CodeQuality.RULES_PATH,
	table.unpack(project.FOLDERS_TO_LINT),
})

local files = findLuaFiles()
if #files > 0 then
	print("[err] the following file(s) are using the '.lua' extension. Please change to '.luau' and try again")
	print(`{table.concat(files, "\n")}`)
	process.exit(1)
end
