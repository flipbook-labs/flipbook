local CodeQuality = require("@lpm/code-quality@v0.8.0")
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local path = require("@std/path")
local process = require("@std/process")

local logger = require("@scripts/lib/logger")
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

run("stylua", {
	"--check",
	table.unpack(project.FOLDERS_TO_LINT),
})

CodeQuality.lint(project.FOLDERS_TO_LINT)

local files = findLuaFiles()
if #files > 0 then
	local fileList = table.concat(files, "\n")
	logger.err(
		`the following file(s) are using the '.lua' extension. Please change to '.luau' and try again\n{fileList}`
	)
	process.exit(1)
end
