local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.12.0")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local project = require("@repo/project")

local run = FlipbookBatteries.run
local findWhere = FlipbookBatteries.findWhere

-- CodeQuality is the org's shared package of Luau lint rules, which `lute lint`
-- runs alongside its own. `lute run install` puts Loom packages in a store under
-- the home folder rather than in this repo, so the rules are read from there.
-- The version in this path has to match the CodeQuality `rev` in
-- loom.config.luau and the check in install.luau.
local CODE_QUALITY_RULES_PATH = path.join(
	process.homedir(),
	".loom",
	"store",
	"CodeQuality@abafa51fdac79cda09bb2e54c6b21af628840b33",
	"src",
	"rules"
)

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

if not fs.exists(CODE_QUALITY_RULES_PATH) then
	print(
		`[err] CodeQuality rules not found at {path.format(CODE_QUALITY_RULES_PATH)}. Run 'lute run install' and try again`
	)
	process.exit(1)
end

-- Lute's parallel linting can crash at random, which fails lint for no reason,
-- so files are linted one at a time: https://github.com/luau-lang/lute/blob/v1.0.1-nightly.20260909/lute/runtime/src/runtime.cpp#L113-L117
run("lute", {
	"lint",
	"--sequential",
	"--rules",
	path.format(CODE_QUALITY_RULES_PATH),
	table.unpack(project.FOLDERS_TO_LINT),
})

local files = findLuaFiles()
if #files > 0 then
	print("[err] the following file(s) are using the '.lua' extension. Please change to '.luau' and try again")
	print(`{table.concat(files, "\n")}`)
	process.exit(1)
end
