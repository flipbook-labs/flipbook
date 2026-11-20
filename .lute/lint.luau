local CodeQuality = require("@lpm/code-quality@v0.5.0")
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

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

type LintReport = {
	items: {
		{
			uri: string,
			items: {
				{
					code: string?,
					message: string,
					range: { start: { line: number, character: number } },
				}
			},
		}
	},
}

-- CodeQuality is the org's shared package of Luau lint rules, which `lute lint`
-- runs alongside its own.
--
-- `lute lint` exits cleanly even when a rule throws or a file can't be parsed.
-- It only prints an error and moves on. So the findings go to a JSON file
-- instead of the terminal, and anything `lute lint` still prints counts as a
-- failure. The codebase doesn't pass every rule yet, so the findings in the
-- report are printed as warnings without failing this script. It lints one
-- file at a time because Lute's parallel linting can crash at random
-- (flipbook-labs/code-quality#27). The report's name includes this process's
-- id, so lint runs in other checkouts can't overwrite it.
local reportPath = path.join(system.tmpdir(), `flipbook-lint-{process.pid()}.json`)
local lintResult = process.run({
	"lute",
	"lint",
	"--sequential",
	"--json",
	"--output",
	path.format(reportPath),
	"--rules",
	CodeQuality.RULES_PATH,
	table.unpack(project.FOLDERS_TO_LINT),
})

local lintOutput = lintResult.stdout .. lintResult.stderr
if not lintResult.ok or lintOutput:find("%S") then
	print("[err] lute lint failed")
	print(lintOutput)
	process.exit(1)
end

local report = json.deserialize(fs.readFileToString(reportPath)) :: LintReport
fs.remove(reportPath)

local findingCount = 0
for _, file in report.items do
	for _, finding in file.items do
		findingCount += 1
		local start = finding.range.start
		print(`{file.uri}:{start.line + 1}:{start.character + 1}: [{finding.code or "lint"}] {finding.message}`)
	end
end

if findingCount > 0 then
	print(`[warn] lute lint reported {findingCount} finding(s). They don't fail lint yet`)
end

local files = findLuaFiles()
if #files > 0 then
	print("[err] the following file(s) are using the '.lua' extension. Please change to '.luau' and try again")
	print(`{table.concat(files, "\n")}`)
	process.exit(1)
end
