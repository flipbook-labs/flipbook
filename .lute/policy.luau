local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")

local REQUIRED_GREPTILE_FILES = {
	"AGENTS.md",
	".github/MERGE_POLICY.md",
	".agents/skills/README.md",
	".agents/skills/flipbook-change-control/SKILL.md",
}

local REQUIRED_PR_TEMPLATE_MARKERS = {
	"## Problem",
	"## Solution",
	"## Ownership",
	"- [ ] Flipbook App",
	"- [ ] Flipbook Engine",
	"## Screenshots",
	"### Before",
	"### After",
	"## Testing",
	"## Notes for reviewers",
}

local function readFile(filePath: string): string
	assert(fs.exists(filePath), `missing required file {filePath}`)
	return fs.readFileToString(path.resolve(filePath))
end

local function readJson(filePath: string): any
	return json.deserialize(readFile(filePath))
end

local function expect(value: any, expectedType: string, name: string): any
	assert(typeof(value) == expectedType, `{name} must be a {expectedType}`)
	return value
end

local function validateMarkers(filePath: string, markers: { string })
	local contents = readFile(filePath)
	local cursor = 1
	for _, marker in markers do
		local beginIndex, endIndex = contents:find(marker, cursor, true)
		assert(beginIndex ~= nil and endIndex ~= nil, `{filePath} is missing required marker "{marker}"`)
		cursor = endIndex + 1
	end
end

local function validateGreptileContext()
	local filesConfig = readJson(".greptile/files.json")
	local files = expect(filesConfig.files, "table", ".greptile/files.json files")
	assert(
		#files == #REQUIRED_GREPTILE_FILES,
		`.greptile/files.json must contain exactly {#REQUIRED_GREPTILE_FILES} initial-load files`
	)

	for index, expectedPath in REQUIRED_GREPTILE_FILES do
		local entry = expect(files[index], "table", `.greptile/files.json files[{index}]`)
		assert(entry.path == expectedPath, `.greptile/files.json files[{index}] must be "{expectedPath}"`)
		expect(entry.description, "string", `.greptile/files.json files[{index}].description`)
		assert(fs.exists(entry.path), `Greptile initial-load file does not exist: {entry.path}`)
	end

	local greptileConfig = readJson(".greptile/config.json")
	local rulesetConfig = readJson(".github/ruleset.json")
	local greptileRequired = false
	for _, check in expect(rulesetConfig.requiredChecks, "table", ".github/ruleset.json requiredChecks") do
		if check.context == "Greptile Review" then
			greptileRequired = true
			break
		end
	end
	assert(
		greptileConfig.statusCheck == greptileRequired,
		"Greptile statusCheck and the required Greptile Review ruleset check must be enabled or disabled together"
	)
end

local function validateSkills()
	local agentsIndex = readFile("AGENTS.md")
	local skillCount = 0
	local result = process.run({ "git", "ls-files", ".agents/skills/*/SKILL.md" })
	assert(result.ok, "failed to list tracked agent skills")
	for skillPath in result.stdout:gmatch("[^\r\n]+") do
		local skillName = path.basename(path.dirname(skillPath))

		skillCount += 1
		local contents = readFile(skillPath)
		local frontmatter = contents:match("^%-%-%-\n(.-)\n%-%-%-")
		assert(frontmatter ~= nil, `{skillPath} must begin with YAML frontmatter`)
		assert(frontmatter:match("^name:%s*([^\n]+)") == skillName, `{skillPath} name must match its directory`)
		assert(frontmatter:match("\ndescription:%s*[^\n]+") ~= nil, `{skillPath} must declare a description`)
		local skillType = frontmatter:match("\ntype:%s*([^\n]+)")
		assert(skillType == "process" or skillType == "knowledge", `{skillPath} type must be process or knowledge`)
		assert(agentsIndex:find(`\`{skillName}\``, 1, true) ~= nil, `{skillPath} must be indexed in AGENTS.md`)
	end
	assert(skillCount > 0, "no agent skills were found")
end

local function validateProtectedSourceInvariants()
	local pluginStarter = readFile("src/PluginStarterScript.plugin.luau")
	assert(
		pluginStarter:find("Charm.flags.frozen = false", 1, true) ~= nil,
		"src/PluginStarterScript.plugin.luau must preserve the Storyteller frozen-state workaround"
	)
end

local function main(arguments: { string })
	local parser = cli.parser()
	parser:add("action", "positional", { help = 'Must be "validate"', default = "validate" })

	table.remove(arguments, 1)
	parser:parse(arguments)
	assert(parser:get("action") == "validate", `unsupported action "{parser:get("action")}"`)

	validateMarkers(".github/pull_request_template.md", REQUIRED_PR_TEMPLATE_MARKERS)
	validateGreptileContext()
	validateSkills()
	validateProtectedSourceInvariants()

	print(`Repository policy is valid ({#REQUIRED_GREPTILE_FILES} Greptile context files).`)
end

local result = { pcall(main, { ... }) } :: { any }
if not result[1] then
	print(`Policy validation failed: {result[2]}`)
	process.exit(1)
end
