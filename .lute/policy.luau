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

local function validateGreptileContext()
	local filesConfig = json.deserialize(fs.readFileToString(".greptile/files.json"))
	assert(typeof(filesConfig.files) == "table", ".greptile/files.json files must be a table")
	local files = filesConfig.files
	assert(
		#files == #REQUIRED_GREPTILE_FILES,
		`.greptile/files.json must contain exactly {#REQUIRED_GREPTILE_FILES} initial-load files`
	)

	for index, expectedPath in REQUIRED_GREPTILE_FILES do
		local entry = files[index]
		assert(typeof(entry) == "table", `.greptile/files.json files[{index}] must be a table`)
		assert(entry.path == expectedPath, `.greptile/files.json files[{index}] must be "{expectedPath}"`)
		assert(
			typeof(entry.description) == "string",
			`.greptile/files.json files[{index}].description must be a string`
		)
		assert(fs.exists(entry.path), `Greptile initial-load file does not exist: {entry.path}`)
	end

	local greptileConfig = json.deserialize(fs.readFileToString(".greptile/config.json"))
	local rulesetConfig = json.deserialize(fs.readFileToString(".github/ruleset.json"))
	assert(typeof(rulesetConfig.requiredChecks) == "table", ".github/ruleset.json requiredChecks must be a table")
	local greptileRequired = false
	for _, check in rulesetConfig.requiredChecks do
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
	local agentsIndex = fs.readFileToString("AGENTS.md")
	local skillCount = 0
	local result = process.run({ "git", "ls-files", ".agents/skills/*/SKILL.md" })
	assert(result.ok, "failed to list tracked agent skills")
	for skillPath in result.stdout:gmatch("[^\r\n]+") do
		local skillName = path.basename(path.dirname(skillPath))

		skillCount += 1
		local contents = fs.readFileToString(skillPath)
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
	local pluginStarter = fs.readFileToString("src/PluginStarterScript.plugin.luau")
	assert(
		pluginStarter:find("Charm.flags.frozen = false", 1, true) ~= nil,
		"src/PluginStarterScript.plugin.luau must preserve the Storyteller frozen-state workaround"
	)
end

validateGreptileContext()
validateSkills()
validateProtectedSourceInvariants()

print(`Repository policy is valid ({#REQUIRED_GREPTILE_FILES} Greptile context files).`)
