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

-- `lute lint` exits with an error when it reports any warning, and the
-- codebase doesn't pass every rule yet. Until it does, warnings are printed
-- without failing this script. The JSON output tells warnings apart from a real
-- failure, because `lute lint --json` exits cleanly when all it found was
-- warnings.
--
-- Both runs lint one file at a time. Lute's parallel linting can crash at
-- random, which fails lint for no reason.
local lintArgs = {
	"lute",
	"lint",
	"--sequential",
	-- CodeQuality is the org's shared package of Luau lint rules, which
	-- `lute lint` runs alongside its own.
	"--rules",
	CodeQuality.RULES_PATH,
	table.unpack(project.FOLDERS_TO_LINT),
}

local lintResult = process.run(lintArgs, {
	stdio = "inherit",
})
if not lintResult.ok then
	local jsonArgs = table.clone(lintArgs)
	table.insert(jsonArgs, 3, "--json")

	local jsonResult = process.run(jsonArgs)
	if not jsonResult.ok then
		print("[err] lute lint failed")
		print(jsonResult.stderr)
		process.exit(1)
	end

	print("[warn] lute lint reported warnings. They don't fail lint yet")
end

local files = findLuaFiles()
if #files > 0 then
	print("[err] the following file(s) are using the '.lua' extension. Please change to '.luau' and try again")
	print(`{table.concat(files, "\n")}`)
	process.exit(1)
end
